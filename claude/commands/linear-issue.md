Work on a Linear issue end-to-end: fetch the issue, plan, implement, and open a PR.

## Usage
`/linear-issue <ISSUE-ID>` (e.g. `/linear-issue ENG-123`)

## Steps

### 1. Fetch the issue
Use the Linear MCP to fetch the issue with ID `$ARGUMENTS`. Display:
- Title and description
- Acceptance criteria (if any)
- Current status and assignee

### 2. Plan
Analyze the codebase as needed and produce a clear implementation plan:
- What files will be created or modified
- High-level approach for each change
- Any risks or open questions

**Stop and wait for the user to approve the plan before proceeding.**

### 3. Mark as In Progress + create branch
Once the user approves:
1. Use the Linear MCP to transition the issue status to **In Progress**.
2. Determine the branch prefix based on the issue type: `feat/` for new features, `fix/` for bugs.
3. Create and checkout a branch named `<prefix>/<issue-id>-short-description` (e.g. `feat/eng-123-add-login`):
   ```
   git checkout -b <branch-name>
   ```

### 4. Implement
Execute the approved plan. Follow the project's conventions and the instructions in CLAUDE.md.

### 5. Mark as In Review + open PR
When the implementation is complete:
1. Commit the changes and push the branch.
2. Use the Linear MCP to transition the issue status to **In Review**.
3. Create a pull request using `gh pr create`. Reference the Linear issue ID in the PR title or body.
