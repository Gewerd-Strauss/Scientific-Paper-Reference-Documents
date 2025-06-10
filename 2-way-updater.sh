#!/bin/bash
set -e

cd "$(git rev-parse --show-toplevel)"

repo_name=$(basename "$(pwd)")
remote="origin"
branch=$(git rev-parse --abbrev-ref HEAD)

# Fetch remote refs
git fetch "$remote"
git fetch "$remote"
git fetch "$remote"

# Resolve commit hashes
local_commit=$(git rev-parse "$branch")
remote_commit=$(git rev-parse "$remote/$branch")
base_commit=$(git merge-base "$branch" "$remote/$branch")

# Check for divergence
if [[ "$base_commit" != "$local_commit" && "$base_commit" != "$remote_commit" ]]; then
  echo "ERROR: repo '$repo_name' has divergent history on remote. Remote not merged, local not pushed. Please resolve yourself. Skipping '$repo_name'"
  exit 1
fi

# If local is behind or equal to remote, fast-forward pull
if [[ "$base_commit" = "$local_commit" && "$base_commit" != "$remote_commit" ]]; then
  echo "[*] Local branch '$branch' is behind remote. Pulling fast-forward..."
  if ! git merge --ff-only "$remote/$branch"; then
    echo "ERROR: repo '$repo_name' failed fast-forward merge on pull."
    exit 1
  fi
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
