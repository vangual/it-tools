# Rebase Guide for Van Branches onto chore/all-my-stuffs

## Overview

This document provides the necessary commands to rebase all branches starting with "van" onto the `chore/all-my-stuffs` branch, which contains the latest features and improvements.

## Branch Analysis

### Source Branches (to be rebased)

1. **van/devel** - Main development branch
   - Currently at: `75a7bbd`
   - Contains: 13 commits (12 unique commits + 1 merge commit)
   - Merge base with target: `8d1d069`

2. **van/tools/favimpexp** - Tool/workflow development
   - Currently at: `fbd3105`
   - Contains: 10 commits
   - Merge base with target: `d80207b`

3. **van/workflows** - Workflow configuration
   - Currently at: `163f697`
   - Contains: 12 commits (superset of favimpexp)
   - Merge base with target: `d80207b`

### Target Branch

- **chore/all-my-stuffs**
  - Currently at: `77e0135`
  - Contains: 529+ commits ahead of the merge bases
  - Latest comprehensive feature branch

## Rebase Strategy

The `chore/all-my-stuffs` branch is significantly ahead of all van branches (529+ commits). The rebase will:

1. Take each van branch's unique commits
2. Replay them on top of the latest `chore/all-my-stuffs` commit
3. Preserve the commit history while incorporating all new features

## Rebase Commands

### Prerequisites

```bash
# Ensure you have all branches locally
git fetch origin

# Create backup branches (recommended)
git branch van/devel-backup van/devel
git branch van/tools/favimpexp-backup van/tools/favimpexp
git branch van/workflows-backup van/workflows
```

### Option 1: Rebase van/workflows (Recommended First)

This branch contains workflow configuration and is a superset of van/tools/favimpexp - recommended to rebase first as it contains all the work from other branches.

```bash
# Checkout the branch to rebase
git checkout van/workflows

# Rebase onto chore/all-my-stuffs
git rebase chore/all-my-stuffs

# If conflicts occur, resolve them and continue:
# 1. Fix conflicts in the files
# 2. git add <resolved-files>
# 3. git rebase --continue

# After successful rebase, push (force push required)
git push origin van/workflows --force
```

### Option 2: Rebase van/tools/favimpexp

This branch contains tool and workflow additions.

```bash
# Checkout the branch to rebase
git checkout van/tools/favimpexp

# Rebase onto chore/all-my-stuffs
git rebase chore/all-my-stuffs

# If conflicts occur, resolve them:
# 1. Fix conflicts in the files
# 2. git add <resolved-files>
# 3. git rebase --continue

# After successful rebase, push (force push required)
git push origin van/tools/favimpexp --force
```

### Option 3: Rebase van/devel (Most Complex)

This branch has already merged chore/all-my-stuffs but is behind. It contains 12 unique feature commits.

**Important**: This branch currently has a merge commit. Rebasing will linearize the history.

```bash
# Checkout the branch to rebase
git checkout van/devel

# Option A: Rebase keeping only unique commits (recommended)
# This will rebase the 12 unique commits after the last merge
git rebase --onto chore/all-my-stuffs 8d1d069

# Option B: Full rebase from merge base
git rebase chore/all-my-stuffs

# If conflicts occur, resolve them:
# 1. Fix conflicts in the files
# 2. git add <resolved-files>
# 3. git rebase --continue

# After successful rebase, push (force push required)
git push origin van/devel --force
```

## Alternative: Merge Strategy

If rebasing proves too complex due to conflicts, you can use a merge strategy instead:

```bash
# For each van branch:
git checkout <van-branch-name>
git merge chore/all-my-stuffs

# Resolve any conflicts
git add <resolved-files>
git commit

# Push the merged branch
git push origin <van-branch-name>
```

## Handling Conflicts

Common conflict areas to watch for:

1. **Package dependencies** (`package.json`, `pnpm-lock.yaml`)
   - Usually safe to accept the version from `chore/all-my-stuffs`
   
2. **Tool index files** (`src/tools/index.ts`)
   - Need to merge both sets of tool registrations
   
3. **Component definitions** (`components.d.ts`)
   - May need to combine both sets of components

4. **Workflow files** (`.github/workflows/*`)
   - Review carefully to preserve custom workflow logic

### Conflict Resolution Process

1. When a conflict occurs:
   ```bash
   # View conflicted files
   git status
   
   # View the conflict
   git diff <file>
   ```

2. Edit the conflicted files to resolve conflicts

3. Stage the resolved files:
   ```bash
   git add <resolved-files>
   ```

4. Continue the rebase:
   ```bash
   git rebase --continue
   ```

5. If you need to abort:
   ```bash
   git rebase --abort
   ```

## Verification After Rebase

After rebasing each branch:

```bash
# Check the branch history
git log --oneline --graph -20

# Verify the branch is on top of chore/all-my-stuffs
git log --oneline chore/all-my-stuffs..HEAD

# Build and test
pnpm install
pnpm build
pnpm test
```

## Recovery from Backup

If something goes wrong:

```bash
# Restore from backup
git checkout van/devel
git reset --hard van/devel-backup

# Delete the backup when done
git branch -D van/devel-backup
```

## Summary of Commands (Quick Reference)

```bash
# Create backups
git branch van/devel-backup van/devel
git branch van/tools/favimpexp-backup van/tools/favimpexp
git branch van/workflows-backup van/workflows

# Rebase van/workflows
git checkout van/workflows
git rebase chore/all-my-stuffs
git push origin van/workflows --force

# Rebase van/tools/favimpexp
git checkout van/tools/favimpexp
git rebase chore/all-my-stuffs
git push origin van/tools/favimpexp --force

# Rebase van/devel (use --onto to skip old merged commits)
git checkout van/devel
git rebase --onto chore/all-my-stuffs 8d1d069
git push origin van/devel --force
```

## Notes

- Force push (`--force`) is required because rebasing rewrites commit history
- Create backup branches before starting
- Test thoroughly after each rebase
- Consider rebasing one branch at a time to isolate issues
- The `chore/all-my-stuffs` branch is 529+ commits ahead, so expect some conflicts
- Communication with team members is important before force-pushing shared branches
