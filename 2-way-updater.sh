#!/bin/bash
set -e

# cd "$(dirname "$0")"
cd "$(git rev-parse --show-toplevel)"


repo_name=$(basename "$(pwd)")
remote="origin"
branch=$(git rev-parse --abbrev-ref HEAD)

# Fetch remote refs
git fetch "$remote"

# Check commit relationships
local_commit=$(git rev-parse "$branch")
remote_commit=$(git rev-parse "$remote/$branch")

# Check if local is ancestor of remote (local behind or equal)
if git merge-base --is-ancestor "$local_commit" "$remote_commit"; then
  # Local is behind or equal — safe to pull fast-forward
  echo "[*] Local branch '$branch' is behind or equal remote. Pulling..."

  # Do a strict fast-forward pull (no merge commits)
  if ! git merge --ff-only "$remote/$branch"; then
    echo "ERROR: repo '$repo_name' failed fast-forward merge on pull."
    exit 1
  fi

# Check if remote is ancestor of local (local ahead of remote)
elif git merge-base --is-ancestor "$remote_commit" "$local_commit"; then
  # Local ahead of remote — divergence
  echo "ERROR: repo '$repo_name' has divergent history on remote. Remote not merged, local not pushed. Please resolve yourself. Skipping '$repo_name'"
  exit 1

else
  # Neither is ancestor of the other — histories have diverged
  echo "ERROR: repo '$repo_name' has divergent history on remote. Remote not merged, local not pushed. Please resolve yourself. Skipping '$repo_name'"
  exit 1
fi

# Stage and commit local changes if any
git add .
if git diff --cached --quiet; then
  echo "[*] No changes to commit."
else
  timestamp=$(date +"%Y%m%d%H%M%S")
  git commit -m "Update $timestamp"
fi

# Push changes
echo "[*] Pushing changes to $remote/$branch..."
git push "$remote" "$branch"
