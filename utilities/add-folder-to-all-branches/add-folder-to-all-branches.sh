#!/usr/bin/env bash
#
# add-folder-to-all-branches.sh
# Adds a given folder to all branches by copying it from the current branch
# and committing on each branch. Output is shown in the console and written
# to add-folder-to-all-branches.log (log is cleared at the start of each run).
#

set -e

# Resolve script directory so we can write the log file next to the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="${SCRIPT_DIR}/add-folder-to-all-branches.log"

# -----------------------------------------------------------------------------
# Logging: clear log at start of each run, then write to log and show in console
# -----------------------------------------------------------------------------
: > "$LOGFILE"
# Write session header (timestamp and full command) for this run
{
  echo "========== $(date '+%Y-%m-%dT%H:%M:%S%z') =========="
  echo "Command: $0 $*"
  echo "========================================"
  echo ""
} >> "$LOGFILE"

# From here on, every stdout/stderr line is shown in the console and appended to the log
exec > >(tee -a "$LOGFILE") 2>&1

# Print RUN SUMMARY block (single place for formatting)
print_run_summary() {
  local all_branches="$1" updated="$2" not_updated="$3"
  echo "----------------------------------------------------------------------"
  echo "RUN SUMMARY"
  echo "----------------------------------------------------------------------"
  echo "  Branches in the repo:     ${all_branches}"
  echo "  Branches updated:        ${updated}"
  echo "  Branches NOT updated:    ${not_updated}"
  echo "----------------------------------------------------------------------"
  echo ""
}

# Print checkout failure message and RUN SUMMARY, then caller should exit
report_checkout_failure() {
  local branch="$1" checkout_err="$2"
  echo ""
  echo "=== ERROR: Could not switch to branch '$branch' ==="
  echo ""
  echo "Git reported:"
  printf '%s\n' "$checkout_err" | sed 's/^/  /'
  echo ""
  echo "What happened:"
  echo "  Git refused to switch branches because you have local files (untracked or"
  echo "  modified) that would be overwritten by the target branch. Git does this"
  echo "  to avoid losing your work."
  echo ""
  echo "What to do next:"
  echo "  1. Resolve the working tree (commit or stash your changes), then run this script again:"
  echo "       git add -A && git commit -m 'Your message'   # or:  git stash -u"
  echo "  2. Run this script again from the repository root:"
  echo "       $0 $FOLDER"
  echo ""
  echo "The script stopped here. Current branch: $(git branch --show-current)."
  echo ""
  if [[ ${#BRANCHES_UPDATED[@]} -eq 0 ]]; then
    print_run_summary "${BRANCHES[*]}" "(none)" "${BRANCHES_NOT_UPDATED[*]}"
  else
    print_run_summary "${BRANCHES[*]}" "${BRANCHES_UPDATED[*]}" "${BRANCHES_NOT_UPDATED[*]}"
  fi
}

# -----------------------------------------------------------------------------
# Input: folder path (required single argument)
# -----------------------------------------------------------------------------
if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <path-to-folder>"
  echo "Example: $0 .agents"
  echo "The path is relative to the current working directory (repo root recommended)."
  exit 1
fi

FOLDER="$1"
echo ""
echo "=== Step 0: Input ==="
echo "Folder to add to all branches: $FOLDER"
echo ""

# -----------------------------------------------------------------------------
# Step 1: Check we are inside a Git repository
# -----------------------------------------------------------------------------
echo "=== Step 1: Check Git repository ==="
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: Not inside a Git repository. Run this script from the repo root."
  exit 1
fi
REPO_ROOT="$(git rev-parse --show-toplevel)"
echo "Repository root: $REPO_ROOT"
echo "Result: OK"
echo ""

# -----------------------------------------------------------------------------
# Step 2: Check folder exists on disk (path relative to cwd)
# -----------------------------------------------------------------------------
echo "=== Step 2: Check folder exists ==="
if [[ ! -d "$FOLDER" ]]; then
  echo "ERROR: Folder does not exist or is not a directory: $FOLDER"
  exit 1
fi
# Ensure folder is inside the repository (security and clarity)
FOLDER_ABS=$(cd "$FOLDER" && pwd)
REPO_ABS=$(cd "$REPO_ROOT" && pwd)
if [[ "$FOLDER_ABS" != "$REPO_ABS" && "$FOLDER_ABS" != "$REPO_ABS/"* ]]; then
  echo "ERROR: Folder must be inside the repository: $REPO_ROOT"
  exit 1
fi
echo "Result: OK"
echo ""

# -----------------------------------------------------------------------------
# Step 3: Ensure folder is tracked on current branch (so we can copy from it later)
# -----------------------------------------------------------------------------
ORIGINAL_BRANCH="$(git branch --show-current)"
echo "=== Step 3: Current branch and folder status ==="
echo "Current branch: $ORIGINAL_BRANCH"

# If folder is not in the index, add and commit it on this branch
if ! git ls-files --error-unmatch "$FOLDER" &>/dev/null; then
  echo "Folder is not yet tracked on this branch. Adding and committing..."
  git add "$FOLDER"
  if git diff --cached --quiet; then
    echo "No changes to commit (folder already matches index)."
  else
    git commit -m "Add $FOLDER"
    echo "Committed $FOLDER on $ORIGINAL_BRANCH."
  fi
else
  echo "Folder is already tracked on $ORIGINAL_BRANCH."
fi
echo ""

# This branch is the source of truth for the folder content when we copy to other branches
SOURCE_BRANCH="$ORIGINAL_BRANCH"
echo "Source branch for folder content: $SOURCE_BRANCH"
echo ""

# -----------------------------------------------------------------------------
# Step 4: List all local branches (we will add the folder to each)
# -----------------------------------------------------------------------------
echo "=== Step 4: List branches ==="
BRANCHES=()
while IFS= read -r b; do
  [[ -n "$b" ]] && BRANCHES+=( "$b" )
done < <(git branch --format='%(refname:short)')
echo "Branches (${#BRANCHES[@]}): ${BRANCHES[*]}"
echo ""
if [[ ${#BRANCHES[@]} -eq 0 ]]; then
  echo "No local branches found."
  exit 1
fi

# -----------------------------------------------------------------------------
# Step 5: Add folder to each branch
# -----------------------------------------------------------------------------
# If the folder already exists on a branch: it is replaced with the version
# from the source branch. If that version is identical, no commit is made.
# We track which branches we successfully update for the final RUN SUMMARY.
BRANCHES_UPDATED=()
echo "=== Step 5: Add folder to each branch ==="
for branch in "${BRANCHES[@]}"; do
  echo "--- Branch: $branch ---"
  # Temporarily allow checkout to fail without exiting (we handle it below)
  set +e
  checkout_err=$(git checkout "$branch" 2>&1)
  checkout_exit=$?
  set -e
  if [[ $checkout_exit -ne 0 ]]; then
    # Branches not updated = this one + all after it
    BRANCHES_NOT_UPDATED=()
    for (( i=0; i<${#BRANCHES[@]}; i++ )); do
      [[ "${BRANCHES[i]}" == "$branch" ]] && { BRANCHES_NOT_UPDATED=("${BRANCHES[@]:i}"); break; }
    done
    report_checkout_failure "$branch" "$checkout_err"
    exit 1
  fi
  # Copy folder from source branch into working tree (overwrites if already present)
  git checkout "$SOURCE_BRANCH" -- "$FOLDER"
  git add "$FOLDER"
  if git diff --cached --quiet; then
    echo "  No changes (folder already present and identical)."
  else
    git commit -m "Add $FOLDER"
    echo "  Committed $FOLDER."
  fi
  BRANCHES_UPDATED+=( "$branch" )
  echo ""
done

# -----------------------------------------------------------------------------
# Step 6: Restore original branch and print RUN SUMMARY
# -----------------------------------------------------------------------------
echo "=== Step 6: Restore branch and summary ==="
git checkout "$ORIGINAL_BRANCH"
echo "Restored current branch: $ORIGINAL_BRANCH"
echo ""
echo "Done. Folder '$FOLDER' has been added/updated on all ${#BRANCHES[@]} branches."
echo ""
print_run_summary "${BRANCHES[*]}" "${BRANCHES_UPDATED[*]}" "(none)"
echo "Full output logged to: $LOGFILE"
echo ""
