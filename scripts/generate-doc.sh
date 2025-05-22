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
HOSTING_BASE_PATH="sdk-ios/$VERSION"

mkdir -p "$DOCC_OUTPUT_DIR"

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
                .product(name: "CoreMethods", package: "project")
            ]
        )
    ]
)
EOF

# Create dummy source
echo "// Dummy source for documentation host" > "Sources/$HOST_MODULE/DocHost.swift"

# Resolve dependencies
swift package resolve

# Generate DocC documentation
xcodebuild docbuild \
  -scheme "$HOST_MODULE" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath .build \
  DOCC_OUTPUT_DIR="/docs" \
  OTHER_DOCC_FLAGS="--transform-for-static-hosting --output-path $VERSIONED_OUTPUT_DIR --hosting-base-path $HOSTING_BASE_PATH"

touch "$DOCC_OUTPUT_DIR/.nojekyll"

cat > "$DOCC_OUTPUT_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url=./latest/documentation/coremethods" />
    <title>Redirecting...</title>
  </head>
  <body>
    <p>If you are not redirected automatically, <a href="./latest/documentation/coremethods">click here</a>.</p>
  </body>
</html>
EOF

# Update folder latest with the new version
LATEST_DIR="$DOCC_OUTPUT_DIR/latest"

rm -rf "$LATEST_DIR"
cp -R "$VERSIONED_OUTPUT_DIR" "$LATEST_DIR"

echo "✅ DocC documentation generated at: $VERSIONED_OUTPUT_DIR"
echo "✅ Updated 'latest' documentation at: $LATEST_DIR"
