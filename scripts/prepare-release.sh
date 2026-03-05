#!/bin/bash
# prepare-release.sh - Creates a release branch and prepares version changes

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

# Create the release branch
git checkout main
git pull origin main
git checkout -b release/"$VERSION"

# Update version in podspec
PODSPEC_FILE=$(find . -maxdepth 1 -name '*.podspec' | head -n 1)
if [ -z "$PODSPEC_FILE" ]; then
  echo "❌ Error: No .podspec file found."
  exit 1
fi
sed -i '' "s/s.version *= *'[^']*'/s.version = '$VERSION'/" "$PODSPEC_FILE"

# Update version in Swift source
SWIFT_VERSION_FILE=$(find . -path '*/MPSDKVersion.swift' | head -n 1)
if [ -z "$SWIFT_VERSION_FILE" ]; then
  echo "❌ Error: MPSDKVersion.swift not found."
  exit 1
fi
sed -i '' "s/static let version = \".*\"/static let version = \"$VERSION\"/" "$SWIFT_VERSION_FILE"

# Update CHANGELOG if it exists
if [ -f "CHANGELOG.md" ]; then
  LAST_TAG=$(git tag --sort=-v:refname | head -n 1)

  if [ -z "$LAST_TAG" ]; then
    TEMP_CHANGELOG=$(git log --pretty=format:"- %s")
  else
    TEMP_CHANGELOG=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
  fi

  DATE=$(date +"%Y-%m-%d")
  HEADER="## [$VERSION] - $DATE"

  # Use a temp file to safely prepend multiline content
  {
    echo "$HEADER"
    echo ""
    echo "$TEMP_CHANGELOG"
    echo ""
    cat CHANGELOG.md
  } > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md

  echo "✅ CHANGELOG.md updated with new entries"
fi

# Commit all changes
git add .
git commit -m "chore: prepare release version $VERSION"

# Push branch and create PR
git push -u origin release/"$VERSION"

# Create PR using GitHub CLI if available
if command -v gh &> /dev/null; then
  echo "📝 Creating PR for release $VERSION..."
  PR_URL=$(gh pr create \
    --title "Release $VERSION" \
    --body "This PR prepares the release of version $VERSION. Please review the changes before merging." \
    --base main 2>&1) && {
    echo "✅ PR created for release $VERSION"
    echo "🔗 $PR_URL"
  } || {
    echo "⚠️ Failed to create PR via gh CLI: $PR_URL"
    echo "Please create PR manually from branch release/$VERSION to main"
  }
else
  echo "⚠️ GitHub CLI not found. Please create PR manually from branch release/$VERSION to main"
fi

echo "✅ Release $VERSION prepared! Review and merge the PR to trigger the release process."
