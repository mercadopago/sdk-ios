#!/bin/bash

set -e

SCHEME="MercadoPagoSDK"
ARCHIVE_NAME="CoreMethods"
DERIVED_DATA="./build"
OUTPUT_DIR="./docs"
HOSTING_BASE_PATH="/"
DOCCARCHIVE_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/$ARCHIVE_NAME.doccarchive"
PORT=8000

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

# echo '
# <!DOCTYPE html>
# <html lang="en">
#   <head>
#     <meta charset="utf-8">
#     <meta http-equiv="refresh" content="0; url=./documentation/coremethods/index.html">
#     <script>
#       window.location.href = "./documentation/coremethods/index.html";
#     </script>
#     <title>Redirecting...</title>
#   </head>
#   <body>
#     If you are not redirected automatically, <a href="./documentation/coremethods/index.html">click here</a>.
#   </body>
# </html>
# ' > docs/index.html

# echo "✅ Documentation successfully generated at $OUTPUT_DIR/"


echo "🌍 Iniciando servidor local na porta $PORT..."

# Verifica se Python está disponível
if command -v python3 &>/dev/null; then
  echo "Usando Python 3 para servir os arquivos"
  cd "$OUTPUT_DIR" && python3 -m http.server $PORT
elif command -v python &>/dev/null; then
  echo "Usando Python 2 para servir os arquivos"
  cd "$OUTPUT_DIR" && python -m SimpleHTTPServer $PORT
elif command -v npx &>/dev/null; then
  echo "Usando http-server do Node.js para servir os arquivos"
  cd "$OUTPUT_DIR" && npx http-server -p $PORT
else
  echo "⚠️ Nem Python nem Node.js encontrados para servir os arquivos."
  echo "Por favor, navegue até $OUTPUT_DIR e inicie um servidor web manualmente."
  echo "Ou instale Python ou Node.js para usar os servidores embutidos."
  exit 1
fi