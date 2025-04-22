#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/release-sdk.sh <version>"
  exit 1
fi

# 1. Update version in podspec + swift
./scripts/update-version.sh "$VERSION"

# 2. Commit and tag
git add .
git commit -m "Release version $VERSION"
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

# 3. Get last version tag (excluding current one)
LAST_TAG=$(git tag --sort=-creatordate | grep -v "$VERSION" | head -n 1)

echo "📝 Generating changelog from $LAST_TAG to $VERSION..."

# 4. Generate changelog from last tag
if [ -z "$LAST_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s")
else
  CHANGELOG=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
fi

# 5. Create GitHub release (requires gh CLI)
gh release create "$VERSION" \
  --title "Release $VERSION" \
  --notes "$CHANGELOG"

echo "🎉 GitHub release $VERSION created successfully!"
