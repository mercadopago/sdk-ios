#!/bin/bash
# publish-release.sh - Executes after merging a release PR

# This script should be run by CI when a release branch is merged to main
# Verify we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "❌ Error: This script must be run on the main branch"
  exit 1
fi

# Verify this is a merge from a release branch
LAST_COMMIT=$(git log -1 --pretty=%B)
if [[ ! $LAST_COMMIT == *"Merge pull request"* || ! $LAST_COMMIT == *"release/"* ]]; then
  echo "❌ Error: Last commit is not a merge from a release branch"
  exit 1
fi

# Extract version from VERSION file
VERSION=$(cat VERSION)
if [ -z "$VERSION" ]; then
  echo "❌ Error: VERSION file not found or empty"
  exit 1
fi

echo "🚀 Publishing release version $VERSION..."

# Tag the release
git tag "$VERSION"
git push origin "$VERSION"

# Generate changelog from last tag (excluding the one we just created)
PREVIOUS_TAG=$(git tag --sort=-creatordate | grep -v "$VERSION" | head -n 1)

if [ -z "$PREVIOUS_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s" | grep -v "Merge pull request")
else
  CHANGELOG=$(git log "$PREVIOUS_TAG".."$VERSION" --pretty=format:"- %s" | grep -v "Merge pull request")
fi

# Create GitHub release
if command -v gh &> /dev/null; then
  echo "📝 Creating GitHub release $VERSION..."
  gh release create "$VERSION" \
    --title "Release $VERSION" \
    --notes "$CHANGELOG"
else
  echo "⚠️ GitHub CLI not found. GitHub release not created."
fi

# Push to CocoaPods trunk
echo "📦 Publishing to CocoaPods trunk..."
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
pod lib lint "$PODSPEC_FILE" --allow-warnings
pod trunk push "$PODSPEC_FILE" --allow-warnings

echo "✅ Release $VERSION published successfully on GitHub and CocoaPods!"