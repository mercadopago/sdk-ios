#!/bin/bash
# publish-release.sh

VERSION=$(cat VERSION)

if [ -z "$VERSION" ]; then
  echo "❌ Error: VERSION file is empty or not found."
  exit 1
fi

echo "🚀 Publishing release version $VERSION..."

#Check if we are on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "⚠️ Warning: This script should be run on the main branch"
  echo "Current branch: $CURRENT_BRANCH"
  read -p "Do you want to continue anyway? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 1
  fi
fi

# Create release tag
echo "📋 Creating tag $VERSION..."
git tag "$VERSION"
git push origin "$VERSION"

# Generate changelog between tags
PREVIOUS_TAG=$(git tag --sort=-creatordate | grep -v "$VERSION" | head -n 1)

if [ -z "$PREVIOUS_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s" | grep -v "Merge pull request")
else
  CHANGELOG=$(git log "$PREVIOUS_TAG".."$VERSION" --pretty=format:"- %s" | grep -v "Merge pull request")
fi

# Create GitHub release if gh CLI is available
if command -v gh &> /dev/null; then
  echo "📝 Creating GitHub release $VERSION..."
  gh release create "$VERSION" \
    --title "Release $VERSION" \
    --notes "$CHANGELOG"
else
  echo "⚠️ GitHub CLI not found. GitHub release not created."
  echo "Generated changelog:"
  echo "$CHANGELOG"
fi

# Publish to CocoaPods
echo "📦 Publishing to CocoaPods..."
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
pod lib lint "$PODSPEC_FILE" --allow-warnings
pod trunk push "$PODSPEC_FILE" --allow-warnings

echo "✅ Release $VERSION successfully published on GitHub and Cocoapods"