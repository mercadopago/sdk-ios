#!/bin/bash

set -euo pipefail

# Base paths
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$ROOT_DIR/.docc-temp"
VERSION_FILE="$ROOT_DIR/VERSION"
SDK_LOCAL_PATH="$ROOT_DIR"
HOST_MODULE="DocHost"

# Read version from VERSION file
VERSION=$(cat "$VERSION_FILE")

# Only proceed if patch version is 0 (e.g., x.y.0)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.0$ ]]; then
  echo "⚠️  Skipping DocC generation: VERSION ($VERSION) is not a major or minor release."
  exit 0
fi

# Define output paths
DOCC_OUTPUT_DIR="$ROOT_DIR/docs"
VERSIONED_OUTPUT_DIR="$DOCC_OUTPUT_DIR/$VERSION"
LATEST_OUTPUT_DIR="$DOCC_OUTPUT_DIR/latest"

# Passing --transform-for-static-hosting directly to `xcodebuild docbuild`
# makes EVERY target in the scheme independently rerun
# `docc convert --transform-for-static-hosting` against the SAME final output
# directory, with no merge step: whichever target converts last simply
# replaces the whole directory. That's both racy when Xcode builds
# independent target branches in parallel (two docc processes fighting over
# the same directory fail with "couldn't be removed") and wrong once there's
# more than one documented product (the last target's docs silently win,
# discarding every other module's pages).
#
# Instead, build one plain .doccarchive per target (no hosting transform),
# then explicitly `docc merge` only the public product archives we want to
# publish, and run the static-hosting transform once on the merged result.
ARCHIVES_DIR="$TEMP_DIR/.archives"
SCRATCH_DIR="$(mktemp -d /tmp/docc-build.XXXXXX)"
trap 'rm -rf "$SCRATCH_DIR"' EXIT
SCRATCH_VERSIONED_DIR="$SCRATCH_DIR/$VERSION"
SCRATCH_LATEST_DIR="$SCRATCH_DIR/latest"
MERGED_ARCHIVE="$SCRATCH_DIR/Merged.doccarchive"

# Public products to publish docs for (internal modules like MPCore/MPAnalytics
# are intentionally excluded — see "Analytics" section in CLAUDE.md).
PUBLIC_PRODUCTS=(CoreMethods MPApplePay MercadoPagoCheckout)

mkdir -p "$DOCC_OUTPUT_DIR"

# --- Common Setup for DocC Generation ---

# Clean and set up temp package
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/Sources/$HOST_MODULE"
cd "$TEMP_DIR"

# Create temporary Swift Package
cat > Package.swift <<EOF
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "$HOST_MODULE",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "$HOST_MODULE", targets: ["$HOST_MODULE"]),
    ],
    dependencies: [
        .package(path: "$SDK_LOCAL_PATH")
    ],
    targets: [
        .target(
            name: "$HOST_MODULE",
            dependencies: [
                .product(name: "CoreMethods", package: "sdk-ios"),
                .product(name: "MPApplePay", package: "sdk-ios"),
                .product(name: "MercadoPagoCheckout", package: "sdk-ios")
            ]
        )
    ]
)
EOF

# Create dummy source
cat > "Sources/$HOST_MODULE/DocHost.swift" <<EOF
// Dummy source for documentation host
import CoreMethods
import MPApplePay
import MercadoPagoCheckout
EOF

# Resolve dependencies
swift package resolve

# --- Build one plain .doccarchive per target ---
echo "Building DocC archives..."
mkdir -p "$ARCHIVES_DIR"

xcodebuild docbuild \
  -scheme "$HOST_MODULE" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath .build \
  DOCC_OUTPUT_DIR="$ARCHIVES_DIR"

# --- Merge the public product archives into a single combined archive ---
echo "Merging DocC archives: ${PUBLIC_PRODUCTS[*]}..."
MERGE_INPUTS=()
for product in "${PUBLIC_PRODUCTS[@]}"; do
  MERGE_INPUTS+=("$ARCHIVES_DIR/$product.doccarchive")
done

xcrun docc merge \
  "${MERGE_INPUTS[@]}" \
  --synthesized-landing-page-name "Mercado Pago iOS SDK" \
  --output-path "$MERGED_ARCHIVE"

# --- Generate Versioned Documentation ---
echo "Generating documentation for version: $VERSION..."

xcrun docc process-archive transform-for-static-hosting "$MERGED_ARCHIVE" \
  --output-path "$SCRATCH_VERSIONED_DIR" \
  --hosting-base-path "sdk-ios/$VERSION"

rm -rf "$VERSIONED_OUTPUT_DIR"
mkdir -p "$VERSIONED_OUTPUT_DIR"
cp -R "$SCRATCH_VERSIONED_DIR/." "$VERSIONED_OUTPUT_DIR/"

echo "✅ DocC documentation generated at: $VERSIONED_OUTPUT_DIR"

# --- Generate 'latest' Documentation ---
echo "Generating documentation for 'latest'..."

xcrun docc process-archive transform-for-static-hosting "$MERGED_ARCHIVE" \
  --output-path "$SCRATCH_LATEST_DIR" \
  --hosting-base-path "sdk-ios/latest"

# Clean up previous 'latest' output and copy the freshly built one in
rm -rf "$LATEST_OUTPUT_DIR"
mkdir -p "$LATEST_OUTPUT_DIR"
cp -R "$SCRATCH_LATEST_DIR/." "$LATEST_OUTPUT_DIR/"

echo "✅ 'latest' documentation generated at: $LATEST_OUTPUT_DIR"

# --- Final Touches ---
touch "$DOCC_OUTPUT_DIR/.nojekyll"

# Create/update the root index.html to redirect to 'latest'
cat > "$DOCC_OUTPUT_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url=./latest/documentation" />
    <title>Redirecting...</title>
  </head>
  <body>
    <p>If you are not redirected automatically, <a href="./latest/documentation">click here</a>.</p>
  </body>
</html>
EOF

echo "DocC generation process complete."