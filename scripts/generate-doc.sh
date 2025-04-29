#!/bin/bash

set -e

SCHEME="MercadoPagoSDK"
ARCHIVE_NAME="CoreMethods"
DERIVED_DATA="./build"
OUTPUT_DIR="./docs"
HOSTING_BASE_PATH="/"
DOCCARCHIVE_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/$ARCHIVE_NAME.doccarchive"

echo "📘 Generating .doccarchive with xcodebuild..."

xcodebuild docbuild \
  -scheme "$SCHEME" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath "$DERIVED_DATA"

echo "📂 Checking if the file $DOCCARCHIVE_PATH was generated..."

if [ ! -d "$DOCCARCHIVE_PATH" ]; then
  echo "❌ ERROR: .doccarchive not found at $DOCCARCHIVE_PATH"
  exit 1
fi

echo "🌐 Converting .doccarchive into a static website at $OUTPUT_DIR..."

$(xcrun --find docc) process-archive \
  transform-for-static-hosting "$DOCCARCHIVE_PATH" \
  --output-path "$OUTPUT_DIR" \
  --hosting-base-path "$HOSTING_BASE_PATH"

echo '
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=./documentation/coremethods/index.html">
    <script>
      window.location.href = "./documentation/coremethods/index.html";
    </script>
    <title>Redirecting...</title>
  </head>
  <body>
    If you are not redirected automatically, <a href="./documentation/coremethods/index.html">click here</a>.
  </body>
</html>
' > docs/index.html

echo "✅ Documentation successfully generated at $OUTPUT_DIR/"
