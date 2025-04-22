#!/bin/bash

set -e

# 1. Read version from VERSION file
VERSION=$(cat VERSION)

echo "🚀 Starting release for version $VERSION"

# 2. Update version in podspec
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
sed -i '' "s/s.version *= *'[^']*'/s.version = '$VERSION'/" "$PODSPEC_FILE"

# 3. Update MPSDKVersion.swift
VERSION_FILE=$(find . -name 'MPSDKVersion.swift' | head -n 1)
sed -i '' "s/static let version = \".*\"/static let version = \"$VERSION\"/" "$VERSION_FILE"

# 4. Git commit and tag
git add "$PODSPEC_FILE" "$VERSION_FILE" VERSION
git commit -m "chore: release version $VERSION"
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

# 5. Generate changelog from last tag
LAST_TAG=$(git tag --sort=-creatordate | grep -v "$VERSION" | tail -n 1)

if [ -z "$LAST_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s")
else
  CHANGELOG=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
fi

# 6. Create GitHub release
gh release create "$VERSION" \
  --title "Release $VERSION" \
  --notes "$CHANGELOG"

# 7. Push to CocoaPods trunk
echo "📦 Publishing to CocoaPods..."
pod trunk push "$PODSPEC_FILE" --allow-warnings

echo "✅ Release $VERSION published successfully!"
