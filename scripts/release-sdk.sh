#!/bin/bash

VERSION=$(cat VERSION)

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/release-sdk.sh <version>"
  exit 1
fi

# 1. Update version in podspec + Swift
./scripts/update-version.sh "$VERSION"

# 2. Commit and tag
git add .
git commit -m "chore: release version $VERSION"
git tag "$VERSION"
echo "teste1"
git push origin release/"$VERSION"
echo "teste2"
git push origin "$VERSION"
echo "teste3"

# 3. Generate changelog from last tag
LAST_TAG=$(git tag --sort=-creatordate | grep -v "$VERSION" | head -n 1)

echo "📝 Generating changelog from $LAST_TAG to $VERSION..."

if [ -z "$LAST_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s")
else
  CHANGELOG=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
fi

# 4. Create GitHub release (requires gh CLI)
gh release create "$VERSION" \
  --title "Release $VERSION" \
  --notes "$CHANGELOG"

# 5. Push to CocoaPods trunk
echo "📦 Publishing to CocoaPods trunk..."
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
pod lib lint "$PODSPEC_FILE" --allow-warnings
pod trunk push "$PODSPEC_FILE" --allow-warnings

echo "✅ Release $VERSION published on GitHub and CocoaPods!"
