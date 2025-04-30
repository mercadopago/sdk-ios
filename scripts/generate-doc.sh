#!/bin/bash

set -euo pipefail

# Configuration
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$ROOT_DIR/.docc-temp"
DOCC_OUTPUT_DIR="$ROOT_DIR/docs"
SDK_LOCAL_PATH="$ROOT_DIR"
HOST_MODULE="DocHost"
HOSTING_BASE_PATH="sdk-ios" # used in the GitHub Pages URL

# Clean up and create temporary directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/Sources/$HOST_MODULE"

cd "$TEMP_DIR"

# Create temporary Package.swift
cat > Package.swift <<EOF
// swift-tools-version:5.6
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
                .product(name: "CoreMethods", package: "sdk-ios")
            ]
        )
    ]
)
EOF

# Create dummy Swift file
echo "// Dummy source for documentation host" > "Sources/$HOST_MODULE/DocHost.swift"

# Resolve dependencies
swift package resolve

# Generate documentation using xcodebuild
xcodebuild docbuild \
  -scheme "$HOST_MODULE" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath .build \
  DOCC_OUTPUT_DIR="/docs" \
  OTHER_DOCC_FLAGS="--transform-for-static-hosting --output-path $DOCC_OUTPUT_DIR --hosting-base-path $HOSTING_BASE_PATH"

# Create .nojekyll for GitHub Pages
touch "$DOCC_OUTPUT_DIR/.nojekyll"

cat > "$DOCC_OUTPUT_DIR/index.html" <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url=./documentation/coremethods/" />
    <title>Redirecting...</title>
  </head>
  <body>
    <p>If you are not redirected automatically, <a href="./documentation/coremethods/">click here</a>.</p>
  </body>
</html>
EOF

echo "✅ DocC documentation successfully generated at: $DOCC_OUTPUT_DIR"
