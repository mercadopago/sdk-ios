#!/bin/bash

set -e

# Path where the documentation was generated

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_PATH="$ROOT_DIR/docs"
BRANCH="gh-pages"
WORKTREE_PATH="/tmp/docs-deploy"

echo "🧹 Cleaning up previous worktree (if any)..."
git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true

echo "🌿 Adding worktree for branch $BRANCH..."
git worktree add --force "$WORKTREE_PATH" "$BRANCH"

echo "🧼 Removing old files..."
rm -rf "$WORKTREE_PATH"/*

echo "📁 Copying new documentation..."
cp -R "$DOCS_PATH"/* "$WORKTREE_PATH"

echo "🚫 Creating .nojekyll to disable Jekyll processing..."
touch "$WORKTREE_PATH/.nojekyll"

mv .git/hooks/pre-commit .git/hooks/pre-commit.bak
echo "📦 Committing changes..."
cd "$WORKTREE_PATH"
git add .
git commit -m "Update generated documentation"
mv .git/hooks/pre-commit.bak .git/hooks/pre-commit
git push origin "$BRANCH"

echo "🧹 Cleaning up worktree..."
cd -
git worktree remove "$WORKTREE_PATH" --force

echo "✅ Documentation deployment completed successfully!"
