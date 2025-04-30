#!/bin/bash

set -e

# Path where the documentation was generated

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_PATH="$ROOT_DIR/docs"
BRANCH="gh-pages"
WORKTREE_PATH="/tmp/docs-deploy"
HOOK_PATH=".git/hooks/pre-commit"
BACKUP_PATH=".git/hooks/pre-commit.bak"
HOOK_WAS_PRESENT=false


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


if [ -f "$HOOK_PATH" ]; then
  echo "🛑 Disabling pre-commit hook temporarily..."
  mv "$HOOK_PATH" "$BACKUP_PATH"
  HOOK_WAS_PRESENT=true
fi

echo "📦 Committing changes..."
cd "$WORKTREE_PATH"
git add .
git commit -m "Update generated documentation"
git push origin "$BRANCH"



echo "🧹 Cleaning up worktree..."
cd -
git worktree remove "$WORKTREE_PATH" --force


if [ "$HOOK_WAS_PRESENT" = true ]; then
  echo "🔁 Restoring pre-commit hook..."
  mv "$BACKUP_PATH" "$HOOK_PATH"
fi

echo "✅ Documentation deployment completed successfully!"
