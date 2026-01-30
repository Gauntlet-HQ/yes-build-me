# Git Workflow

## Basic Commands

```bash
git status              # Check current state
git add <file>          # Stage changes
git commit -m "message" # Commit changes
git push                # Push to remote
git pull                # Pull from remote
```

## Branching

```bash
git branch              # List branches
git branch <name>       # Create branch
git checkout <name>     # Switch branch
git checkout -b <name>  # Create and switch
git merge <branch>      # Merge branch
```

## Commit Message Convention

```
type(scope): description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructure
- test: Tests
- chore: Maintenance
```

## Viewing History

```bash
git log --oneline       # Compact log
git log -p              # With diffs
git diff                # Unstaged changes
git diff --staged       # Staged changes
```

## Undoing Changes

```bash
git checkout -- <file>  # Discard unstaged changes
git reset HEAD <file>   # Unstage file
git reset --soft HEAD~1 # Undo last commit (keep changes)
```

## Working with Remote

```bash
git remote -v           # List remotes
git fetch               # Download changes
git pull                # Fetch + merge
git push -u origin main # Push and set upstream
```

## Resources

- [Git Documentation](https://git-scm.com/doc)
