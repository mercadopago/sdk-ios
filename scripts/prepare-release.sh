#!/bin/bash
# prepare-release.sh - Creates a release branch and prepares version changes

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/prepare-release.sh <version>"
  exit 1
fi

# Create the release branch
git checkout main
git pull origin main
git checkout -b release/"$VERSION"

# Update version in podspec + Swift
PODSPEC_FILE=$(find . -name '*.podspec' | head -n 1)
sed -i '' "s/s.version *= *'[^']*'/s.version = '$VERSION'/" "$PODSPEC_FILE"

VERSION_FILE=$(find . -name 'MPSDKVersion.swift' | head -n 1)
sed -i '' "s/static let version = \".*\"/static let version = \"$VERSION\"/" "$VERSION_FILE"

# Update CHANGELOG if it exists
if [ -f "CHANGELOG.md" ]; then
  # Generate temporary changelog since previous tag
  LAST_TAG=$(git tag --sort=-creatordate | head -n 1)
  
  if [ -z "$LAST_TAG" ]; then
    TEMP_CHANGELOG=$(git log --pretty=format:"- %s")
  else
    TEMP_CHANGELOG=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
  fi
  
  # Insert at the top of CHANGELOG.md
  DATE=$(date +"%Y-%m-%d")
  sed -i '' "1s/^/## [$VERSION] - $DATE\n\n$TEMP_CHANGELOG\n\n/" CHANGELOG.md
  echo "✅ CHANGELOG.md updated with new entries"
fi

# Commit the changes
git add .
git commit -m "chore: prepare release version $VERSION"

# Push branch and create PR
git push -u origin release/"$VERSION"

# Create PR using GitHub CLI if available
if command -v gh &> /dev/null; then
  echo "📝 Creating PR for release $VERSION..."
  gh pr create \
    --title "Release $VERSION" \
    --body "This PR prepares the release of version $VERSION. Please review the changes before merging." \
    --base main \
    --head release/"$VERSION"
  
  echo "✅ PR created for release $VERSION"
else
  echo "⚠️ GitHub CLI not found. Please create PR manually from branch release/$VERSION to main"
fi

echo "✅ Release $VERSION prepared! Review and merge the PR to trigger the release process."
