-- ~/.config/nvim/lua/gittutor.lua
-- Simple utility module (not a plugin). Load with: require('gittutor').setup()

local M = {}

-- Comprehensive Git tutorial content
local content = {
  " GIT TUTOR — Master Git in Neovim ",
  "==================================",
  "",
  "Git is a distributed version control system. This guide covers essential",
  "commands and workflows to help you use Git confidently.",
  "",
  "📚 TABLE OF CONTENTS",
  "-------------------",
  "1. Configuration & Initialization",
  "2. Basic Workflow (Add → Commit → Push)",
  "3. Viewing Changes & History",
  "4. Branching & Merging",
  "5. Working with Remotes",
  "6. Undoing & Fixing Mistakes",
  "7. Stashing & Cleaning",
  "8. Useful Tips & Aliases",
  "",
  "──────────────────────────────────",
  "1. CONFIGURATION & INITIALIZATION",
  "──────────────────────────────────",
  "Set your identity (required once per system):",
  "  git config --global user.name \"Your Name\"",
  "  git config --global user.email \"you@example.com\"",
  "",
  "Initialize a new repo or clone an existing one:",
  "  git init                     # Create local repo",
  "  git clone <repo-url>         # Copy remote repo locally",
  "  git clone -b <branch> <url>  # Clone specific branch",
  "",
  "──────────────────────────────────",
  "2. BASIC WORKFLOW",
  "──────────────────────────────────",
  "Stage → Commit → Push:",
  "  git add <file>               # Stage specific file",
  "  git add .                    # Stage all changes",
  "  git restore --staged <file>  # Unstage file (newer Git)",
  "  git commit -m \"message\"    # Commit staged changes",
  "  git push origin <branch>     # Upload commits to remote",
  "",
  "──────────────────────────────────",
  "3. VIEWING CHANGES & HISTORY",
  "──────────────────────────────────",
  "Inspect your work:",
  "  git status                   # Overview of changes",
  "  git diff                     # Unstaged changes",
  "  git diff --staged            # Staged (but uncommitted) changes",
  "  git log                      # Commit history (press 'q' to quit)",
  "  git log --oneline            # Compact history",
  "  git log --graph --all        # Visual branch history",
  "  git show <commit>            # Show commit details",
  "",
  "──────────────────────────────────",
  "4. BRANCHING & MERGING",
  "──────────────────────────────────",
  "Branches let you work in isolation:",
  "  git branch                   # List local branches",
  "  git branch -a                # List all (local + remote)",
  "  git checkout -b <new-branch> # Create + switch to branch",
  "  git switch <branch>          # Switch branch (modern)",
  "  git switch -c <branch>       # Create + switch (modern)",
  "",
  "Merge or rebase:",
  "  git merge <branch>           # Merge <branch> into current",
  "  git rebase <branch>          # Rebase current onto <branch>",
  "  git merge --abort            # Cancel merge conflict resolution",
  "",
  "Delete branches:",
  "  git branch -d <branch>       # Delete local branch",
  "  git push origin --delete <branch>  # Delete remote branch",
  "",
  "──────────────────────────────────",
  "5. WORKING WITH REMOTES",
  "──────────────────────────────────",
  "Manage remote repositories:",
  "  git remote -v                # List remotes",
  "  git remote add origin <url>  # Add remote named 'origin'",
  "  git fetch                    # Download updates (no merge)",
  "  git pull origin main         # = fetch + merge (use cautiously!)",
  "  git push -u origin main      # Set upstream for future pushes",
  "",
  "──────────────────────────────────",
  "6. UNDOING & FIXING MISTAKES",
  "──────────────────────────────────",
  "Fix common errors:",
  "  git restore <file>           # Discard unstaged changes",
  "  git restore --staged <file>  # Unstage (was: git reset HEAD <file>)",
  "  git commit --amend           # Modify last commit",
  "  git reset --soft HEAD~1      # Undo commit, keep changes staged",
  "  git reset --hard HEAD~1      # ⚠️ Permanently delete last commit + changes",
  "  git revert <commit>          # Create new commit that undoes <commit>",
  "",
  "──────────────────────────────────",
  "7. STASHING & CLEANING",
  "──────────────────────────────────",
  "Temporarily save work:",
  "  git stash                    # Save dirty state, return to clean HEAD",
  "  git stash list               # View stashes",
  "  git stash pop                # Restore latest stash",
  "  git stash apply              # Restore without removing from stash",
  "  git clean -n                 # Preview files to delete (untracked)",
  "  git clean -f                 # Delete untracked files",
  "",
  "──────────────────────────────────",
  "8. USEFUL TIPS & ALIASES",
  "──────────────────────────────────",
  "Speed up your workflow with aliases (~/.gitconfig):",
  "  [alias]",
  "    s = status",
  "    c = commit",
  "    l = log --oneline",
  "    co = checkout",
  "    br = branch",
  "    unstage = restore --staged",
  "",
  "Pro tip: Always `git status` before committing!",
  "",
  "💡 Practice in a test repo: `mkdir test && cd test && git init`",
  "",
  "Press 'q' to close this window.",
}

-- Opens Gittutor in a floating window
local function open_gittutor()
  local buf = vim.api.nvim_create_buf(false, true)
  if buf == 0 then
    vim.notify("Gittutor: Failed to create buffer", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "gittutor")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "readonly", true)
  vim.api.nvim_buf_set_name(buf, "GITTUTOR")

  -- Quit with 'q'
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  -- Floating window dimensions
  local win_width = math.min(85, vim.o.columns - 4)
  local win_height = math.min(#content + 2, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - win_height) / 2)
  local col = math.floor((vim.o.columns - win_width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:Special")
end

-- Setup function: registers the :Gittutor command
function M.setup()
  vim.api.nvim_create_user_command("Gittutor", open_gittutor, {
    desc = "Open comprehensive Git tutorial in Neovim",
  })
end

return M
