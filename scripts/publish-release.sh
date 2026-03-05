#!/bin/bash
# publish-release.sh

set -euo pipefail

VERSION_FILE="VERSION"

if [ ! -f "$VERSION_FILE" ]; then
  echo "❌ Error: VERSION file not found."
  exit 1
fi

VERSION=$(tr -d '\n\r' < "$VERSION_FILE")

if [ -z "$VERSION" ]; then
  echo "❌ Error: VERSION file is empty."
  exit 1
fi

echo "🚀 Publishing release version $VERSION..."

# Check if we are on the main branch
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

# Ensure main is up to date on remote
echo "📋 Pushing main branch to remote..."
git push origin main

# Create annotated release tag
echo "📋 Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

# Generate changelog between tags
PREVIOUS_TAG=$(git tag --sort=-v:refname | grep -v "^${VERSION}$" | head -n 1)

if [ -z "$PREVIOUS_TAG" ]; then
  CHANGELOG=$(git log --pretty=format:"- %s" | grep -v "Merge pull request" || true)
else
  CHANGELOG=$(git log "$PREVIOUS_TAG".."$VERSION" --pretty=format:"- %s" | grep -v "Merge pull request" || true)
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
PODSPEC_FILE=$(find . -maxdepth 1 -name '*.podspec' | head -n 1)
if [ -z "$PODSPEC_FILE" ]; then
  echo "❌ Error: No .podspec file found."
  exit 1
fi

echo "📦 Validating podspec..."
pod lib lint "$PODSPEC_FILE" --allow-warnings

echo "📦 Publishing to CocoaPods..."
pod trunk push "$PODSPEC_FILE" --allow-warnings

echo "✅ Release $VERSION successfully published on GitHub and CocoaPods"