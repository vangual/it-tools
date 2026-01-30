# Conflict Resolution Guide

## Overview

When rebasing the van branches onto `chore/all-my-stuffs`, you will encounter conflicts. This guide provides specific instructions for resolving them.

## Expected Conflicts

Based on test rebasing, the following conflicts are expected:

### 1. src/tools/index.ts (HIGH PRIORITY)

**Why it conflicts**: Both branches register new tools in the same array/object.

**How to resolve**:
```typescript
// The file exports tools in an array or object
// You need to merge both sets of tool imports and registrations

// Example conflict structure:
<<<<<<< HEAD (chore/all-my-stuffs)
// Tools from chore/all-my-stuffs
import { tool as tcpUdpTester } from '@/tools/tcp-udp-tester';
import { tool as rj45Memo } from '@/tools/rj45-memo';
// ... more tools
=======
// Tools from van branches
import { tool as newVanTool } from '@/tools/new-van-tool';
// ... more tools
>>>>>>> 7bc075bc (Initial tool creation)

// Resolution: Include BOTH sets of imports
import { tool as tcpUdpTester } from '@/tools/tcp-udp-tester';
import { tool as rj45Memo } from '@/tools/rj45-memo';
import { tool as newVanTool } from '@/tools/new-van-tool';
// ... include all tools from both branches

// Then ensure both sets are registered in the tools array
```

**Steps**:
1. Open `src/tools/index.ts` in your editor
2. Find all import statements from both sides
3. Merge them (keep all imports)
4. Find the tool registration array
5. Merge both arrays (keep all tool registrations)
6. Ensure no duplicates
7. Save the file

### 2. components.d.ts (MEDIUM PRIORITY)

**Why it conflicts**: Auto-generated file that lists all components.

**How to resolve**:
```bash
# This file is usually auto-generated
# Option 1: Accept one version and regenerate
git checkout --theirs components.d.ts
pnpm build  # or whatever command regenerates it

# Option 2: Merge both sets of component declarations manually
# Look for component declarations and merge them
```

### 3. package.json (MEDIUM PRIORITY)

**Why it conflicts**: Both branches may add dependencies.

**How to resolve**:
1. Check for new dependencies in both versions
2. Merge the dependencies sections
3. Keep the higher version numbers
4. After resolving, run: `pnpm install`

```json
// Example:
<<<<<<< HEAD
"dependencies": {
  "vue": "^3.4.0",
  "new-dep-from-chore": "^1.0.0"
}
=======
"dependencies": {
  "vue": "^3.3.0",
  "new-dep-from-van": "^2.0.0"
}
>>>>>>> commit

// Resolution:
"dependencies": {
  "vue": "^3.4.0",  // Keep higher version
  "new-dep-from-chore": "^1.0.0",  // Keep both
  "new-dep-from-van": "^2.0.0"     // Keep both
}
```

### 4. pnpm-lock.yaml (LOW PRIORITY)

**Why it conflicts**: Lock file changes with dependency updates.

**How to resolve**:
```bash
# Don't manually edit this file
# Accept one version and regenerate
git checkout --theirs pnpm-lock.yaml
pnpm install
git add pnpm-lock.yaml
```

### 5. .github/workflows/* (HIGH PRIORITY)

**Why it conflicts**: Custom workflow configurations in van branches.

**How to resolve**:
1. Carefully review both versions
2. Identify custom logic specific to van branches
3. Merge the workflows, keeping custom logic
4. Test workflow syntax after merging

```yaml
# If both branches modify the same workflow:
# 1. Keep all jobs from both sides
# 2. Merge environment variables
# 3. Keep custom steps from van branches
# 4. Update any outdated action versions from chore/all-my-stuffs
```

### 6. README.md or Documentation (LOW PRIORITY)

**Why it conflicts**: Documentation updates in both branches.

**How to resolve**:
1. Read both versions
2. Merge the content logically
3. Keep all important information
4. Remove duplicates

## General Conflict Resolution Process

### Step 1: Identify the conflict
```bash
git status
# Look for files marked as "both modified"
```

### Step 2: Examine the conflict
```bash
git diff <conflicted-file>
# Or open in your editor to see conflict markers
```

### Step 3: Resolve the conflict
- Edit the file to remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- Merge the content appropriately
- Keep what's needed from both sides

### Step 4: Mark as resolved
```bash
git add <resolved-file>
```

### Step 5: Continue the rebase
```bash
git rebase --continue
```

### Step 6: If more conflicts, repeat steps 1-5

## Quick Commands Reference

```bash
# View all conflicted files
git status | grep "both modified"

# Accept their version (from chore/all-my-stuffs)
git checkout --theirs <file>

# Accept our version (from van branch)
git checkout --ours <file>

# Abort the rebase if needed
git rebase --abort

# Skip a commit (if it's no longer relevant)
git rebase --skip

# Continue after resolving
git add <resolved-files>
git rebase --continue
```

## Testing After Resolution

After completing the rebase and resolving all conflicts:

```bash
# Install dependencies
pnpm install

# Run linter
pnpm lint

# Run type checker
pnpm typecheck

# Build the project
pnpm build

# Run tests
pnpm test

# Run in development mode to verify
pnpm dev
# Open http://localhost:5173 and test the tools
```

## Common Mistakes to Avoid

1. ❌ **Don't** force-push before testing
2. ❌ **Don't** delete both sides of a conflict without reading
3. ❌ **Don't** forget to rebuild after resolving package.json conflicts
4. ❌ **Don't** skip testing workflow files
5. ❌ **Don't** forget to verify all new tools work

## When to Ask for Help

- If you're unsure which version of code to keep
- If the same conflict appears multiple times
- If tests fail after resolution and you can't figure out why
- If workflow files have complex custom logic

## Pro Tips

1. ✅ Resolve conflicts in multiple small commits rather than one big commit
2. ✅ Test after each few commits during the rebase
3. ✅ Keep a terminal open with `pnpm dev` running to catch issues early
4. ✅ Use a merge tool like VS Code's built-in merger for complex conflicts
5. ✅ Document any non-obvious resolution decisions

## Visual Studio Code Tips

If using VS Code:

1. Install "GitLens" extension for better conflict visualization
2. Click on conflicted files in the Source Control panel
3. Use the "Accept Current Change" / "Accept Incoming Change" / "Accept Both Changes" buttons
4. For complex merges, use the 3-way merge editor (VS Code shows three panels)

## Example: Complete Conflict Resolution Flow

```bash
# Start the rebase
git checkout van/workflows
git rebase chore/all-my-stuffs

# Conflict occurs in src/tools/index.ts
# Output: CONFLICT (content): Merge conflict in src/tools/index.ts

# Open the file and resolve the conflict
code src/tools/index.ts
# Merge the tool imports and registrations

# Mark as resolved
git add src/tools/index.ts

# Continue
git rebase --continue

# Another conflict in package.json
# Output: CONFLICT (content): Merge conflict in package.json

# Resolve it
code package.json
# Merge dependencies

# Mark as resolved and regenerate lock file
git add package.json
pnpm install
git add pnpm-lock.yaml

# Continue
git rebase --continue

# Rebase completes successfully
# Test everything
pnpm build
pnpm test

# If all good, push
git push origin van/workflows --force
```
