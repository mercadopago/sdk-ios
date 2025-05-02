#!/bin/bash

set -euo pipefail

# Setup paths
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_PATH="$ROOT_DIR/docs"
VERSION=$(cat "$ROOT_DIR/VERSION")
BRANCH="gh-pages"
WORKTREE_PATH="/tmp/docs-deploy"

# Optional: Hook paths (if needed to disable pre-commit manually)
HOOK_PATH="$ROOT_DIR/.git/hooks/pre-commit"
BACKUP_PATH="$ROOT_DIR/.git/hooks/pre-commit.bak"
HOOK_WAS_PRESENT=false

echo "🧹 Cleaning up previous worktree (if any)..."
git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true

echo "🌿 Adding worktree for branch $BRANCH..."
git worktree add --force "$WORKTREE_PATH" "$BRANCH"

echo "🧼 Removing old files from worktree..."
rm -rf "$WORKTREE_PATH"/*

echo "📁 Copying versioned documentation..."
cp -R "$DOCS_PATH"/* "$WORKTREE_PATH"

# .nojekyll is already in DOCS_PATH — no need to recreate it

# 🔒 Temporarily disable pre-commit hook (if needed)
if [ -f "$HOOK_PATH" ]; then
  echo "🛑 Disabling pre-commit hook temporarily..."
  mv "$HOOK_PATH" "$BACKUP_PATH"
  HOOK_WAS_PRESENT=true
fi
git config --global user.name "Circle CI"
git config --global user.email "ci-ios@circleci.com"

# 📦 Commit and push changes
cd "$WORKTREE_PATH"
git add .
git commit -m "Deploy documentation for version $VERSION"
git push origin "$BRANCH"

# 🔁 Restore pre-commit hook if it was disabled
if [ "$HOOK_WAS_PRESENT" = true ]; then
  echo "🔁 Restoring pre-commit hook..."
  mv "$BACKUP_PATH" "$HOOK_PATH"
fi

# 🧽 Clean up worktree
cd -
git worktree remove "$WORKTREE_PATH" --force

echo "✅ Documentation for version $VERSION deployed to branch '$BRANCH'."
