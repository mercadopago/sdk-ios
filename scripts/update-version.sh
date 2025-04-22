#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/update-version.sh <version>"
  exit 1
fi

echo "🔧 Updating version to $VERSION..."

# Update .podspec version
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
sed -i '' "s/s.version *= *'[^']*'/s.version = '$VERSION'/" "$PODSPEC_FILE"

# Update Swift version constant
VERSION_FILE=$(find . -name 'MPSDKVersion.swift' | head -n 1)
sed -i '' "s/static let version = \".*\"/static let version = \"$VERSION\"/" "$VERSION_FILE"

echo "✅ Version updated to $VERSION in:"
echo "- $PODSPEC_FILE"
echo "- $VERSION_FILE"
