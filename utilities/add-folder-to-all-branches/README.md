# Add Folder To All Branches

A bash script that adds a given folder to **all local Git branches** in the repository. The folder is copied from the branch you are on when you run the script; every other branch gets that same version (added or updated as needed).

---

## What the script does

- **Input:** You pass a single argument: the path to the folder you want to add to all branches. The path is **relative to the repository root** (the directory that contains `.git`). Examples: `.agents` for a folder at the root, or `docs/config` for a folder inside `docs/`.
- **Where to run:** Run the script **from the repository root**. If your repo is at `~/projects/playground`, open a terminal, go there first with `cd ~/projects/playground`, then run the script.
- **Example commands:**

  ```bash
  cd /path/to/your/repo
  ./utilities/add-folder-to-all-branches/add-folder-to-all-branches.sh .agents
  ```

  (Replace `/path/to/your/repo` with your actual repository path, e.g. `~/projects/playground`. Use `.agents` or whatever folder path you need.)
- **Steps:**
  1. Checks you are inside a Git repository.
  2. Checks the folder exists on disk.
  3. On the **current branch:** if the folder is not yet tracked, adds and commits it. This branch becomes the **source** of the folder content.
  4. Lists all local branches.
  5. For **each local branch:** checks out the branch, copies the folder from the source branch into the working tree, adds it, and commits only if there are changes.
  6. Switches back to the branch you started on and prints a short summary.

- **Output:** Every step is printed to the console. The same output is written to `add-folder-to-all-branches.log` in this directory. The log file is **cleared at the start of each run**, so each run has a fresh log and avoids confusion. The log is ignored by Git (via the repository’s `.gitignore`).

---

## If the folder already exists on a branch

- **Same content:** If the folder is already present on that branch and its contents are **identical** to the source branch, the script does nothing on that branch and prints: `No changes (folder already present and identical).` No commit is made.
- **Different content:** If the folder exists but has **different** files or content, the script **overwrites** it with the version from the source branch and then commits that change. So running the script makes every branch have the same folder content as the branch you ran it from.

---

## Why we created it

Git has no built-in way to “add this folder to every branch.” This script automates the process: you add the folder on one branch (or it’s already there), run the script once, and that folder is added or updated on all local branches without having to merge or manually repeat steps. Useful for shared assets (e.g. `.agents`, config, or docs) that should exist on every branch.

---

## How to use it

1. **Open a terminal and go to the repository root** (the directory that contains `.git`). Example:

   ```bash
   cd /path/to/your/repo
   ```

   (Use your real repo path, e.g. `~/Documents/github/playground` or `cd ~/projects/playground`.)

2. **Run the script with the folder path** (relative to the repo root). Example for a folder named `.agents` at the repo root:

   ```bash
   ./utilities/add-folder-to-all-branches/add-folder-to-all-branches.sh .agents
   ```

   Example for a folder `docs/config` inside the repo:

   ```bash
   ./utilities/add-folder-to-all-branches/add-folder-to-all-branches.sh docs/config
   ```

3. Ensure the folder exists in the repo and you are on the branch whose version you want on all branches (often `main`).
4. The script only updates **local** branches. To update remotes, push after the run (e.g. `git push origin --all` or push branches individually).

**If you run the script without arguments**, it prints usage and exits:

```bash
./utilities/add-folder-to-all-branches/add-folder-to-all-branches.sh
# Usage: ... <path-to-folder>
# Example: ... .agents
```
