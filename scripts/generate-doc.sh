#!/bin/bash

set -euo pipefail

# Configurações
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$ROOT_DIR/.docc-temp"
DOCC_OUTPUT_DIR="$ROOT_DIR/docs"
SDK_LOCAL_PATH="$ROOT_DIR"
HOST_MODULE="DocHost"
HOSTING_BASE_PATH="sdk-ios" # usado na URL do GitHub Pages

# Limpa e cria diretório temporário
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR/Sources/$HOST_MODULE"

cd "$TEMP_DIR"

# Cria Package.swift temporário
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

# Cria arquivo Swift dummy
echo "// Dummy source for documentation host" > "Sources/$HOST_MODULE/DocHost.swift"

# Resolve dependências
swift package resolve

# Gera documentação com xcodebuild
xcodebuild docbuild \
  -scheme "$HOST_MODULE" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath .build \
  DOCC_OUTPUT_DIR="/docs" \
  OTHER_DOCC_FLAGS="--transform-for-static-hosting --output-path $DOCC_OUTPUT_DIR --hosting-base-path $HOSTING_BASE_PATH"

# Cria .nojekyll para GitHub Pages
touch "$DOCC_OUTPUT_DIR/.nojekyll"

echo "✅ Documentação DocC gerada em: $DOCC_OUTPUT_DIR"