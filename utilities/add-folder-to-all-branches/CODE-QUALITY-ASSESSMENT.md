# Code quality assessment: `add-folder-to-all-branches.sh`

**Assessment date:** After applying previous fixes (portable date, REPO_ROOT validation, empty-branch check, `print_run_summary`, `report_checkout_failure`, shortened not-updated loop).

---

## 1. Explanation

The script adds a **single folder** to **all local Git branches**. It is intended for repos where the same directory (e.g. `.agents`, config, or docs) should exist on every branch without merging.

**What it does:**

- Takes one argument: the path to the folder (relative to the current working directory).
- Validates: inside a Git repo, folder exists on disk, and folder is **inside the repository** (resolved against repo root).
- On the **current branch**: if the folder is not tracked, it adds and commits it. That branch becomes the **source** of the folder content.
- Lists all local branches; if none exist, exits with "No local branches found."
- For **each local branch**: checks out the branch, copies the folder from the source branch into the working tree (overwriting if present), adds and commits only if there are changes. Tracks which branches were updated for the final summary.
- If `git checkout` fails (e.g. untracked or modified files would be overwritten), calls `report_checkout_failure`, which prints a clear error, "What happened", "What to do next", and a RUN SUMMARY (branches in repo, updated, not updated), then exits.
- On success: restores the original branch and prints a RUN SUMMARY via `print_run_summary`. All output is also written to `add-folder-to-all-branches.log` (log is cleared at the start of each run; portable timestamp format).

---

## 2. Recursive component / dependency list

- **add-folder-to-all-branches.sh** (assessed)
  - **Bash** (shell, built-ins: `set`, `exec`, arrays, `[[`, `$()`, functions, etc.)
  - **git** (external)
    - `git rev-parse`, `git branch`, `git checkout`, `git add`, `git commit`, `git ls-files`, `git diff`
  - **date** (external; portable format `date '+%Y-%m-%dT%H:%M:%S%z'` for timestamp)
  - **tee** (external; `tee -a` for logging)
  - **sed** (external; `sed 's/^/  /'` for indentation)
  - **printf** (shell built-in)

No project-internal modules or imports; only the shell, Git, and standard Unix utilities.

---

## 3. Bugs

No bugs identified in the current version. Previous issues have been addressed:

- **REPO_ROOT** is used in Step 2 to validate that the folder (resolved to an absolute path) lies inside the repository.
- **Date** uses the portable format `date '+%Y-%m-%dT%H:%M:%S%z'`.
- **Empty branch list** is handled by exiting with "No local branches found." after building `BRANCHES`.

---

## 4. Simplification

The script is already well structured with `print_run_summary` and `report_checkout_failure`. Optional minor improvement:

- **Step 3 block (ensure folder tracked):** The block that adds/commits the folder on the current branch if not tracked (lines ~126–138) could be extracted into a function, e.g. `ensure_folder_tracked_on_current_branch`, so the main flow reads as: validate repo → validate folder → ensure folder tracked → list branches → loop over branches. This would not change behavior; it would only shorten the main script and make the intent of Step 3 more obvious at a glance.

---

## 5. Security

### 5.1 User-controlled folder path — **ADDRESSED**

```bash
# Ensure folder is inside the repository (security and clarity)
FOLDER_ABS=$(cd "$FOLDER" && pwd)
REPO_ABS=$(cd "$REPO_ROOT" && pwd)
if [[ "$FOLDER_ABS" != "$REPO_ABS" && "$FOLDER_ABS" != "$REPO_ABS/"* ]]; then
  echo "ERROR: Folder must be inside the repository: $REPO_ROOT"
  exit 1
fi
```

- **Severity:** Was `low`; now addressed.
- **Fix in place:** The script resolves `FOLDER` and `REPO_ROOT` to absolute paths and ensures `FOLDER_ABS` is equal to or under `REPO_ABS`. Paths outside the repository are rejected before any `git checkout` or `git add` with the folder path.

### 5.2 Log file path

`LOGFILE` is under `SCRIPT_DIR`, which is derived from the script’s location. No user input is used there. No change needed.

---

## 6. Performance

- **Git calls:** One checkout and one “copy folder” per branch; appropriate for the task.
- **Arrays:** Building `BRANCHES`, `BRANCHES_UPDATED`, and `BRANCHES_NOT_UPDATED` is O(n) in the number of branches; acceptable.
- **Subshells:** Used only for the session header and for `tee`; no hot-path concern.

No performance changes suggested.

---

## 7. Overall assessment

| Aspect          | Notes |
| --------------- | ----- |
| Correctness     | Logic is sound; edge cases (checkout failure, empty branches, path outside repo) are handled. |
| Clarity         | Steps, comments, and RUN SUMMARY are clear; helpers improve readability. |
| Robustness      | Portable date, repo/folder validation, empty-branch check, and clear error handling. |
| Security        | User-supplied folder path is validated to lie inside the repository. |
| Maintainability  | Single place for RUN SUMMARY and for checkout-failure reporting; loop for “not updated” is concise. |

**Quality score: 90 / 100**

The script fulfills its purpose, is readable, and handles failures and edge cases well. Previous issues (unused variable, non-portable date, empty branches, duplicated summary, long error block, path validation) have been fixed. The remaining 10 points could come from optional refactors (e.g. extracting the “ensure folder tracked” block into a function) and from the inherent complexity of multi-branch Git operations.
