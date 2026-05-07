-- linuxtutor.lua
-- Interactive Linux CLI tutorial for Neovim

local M = {}

local function create_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Linux CLI Tutor ',
    title_pos = 'center',
  })

  vim.api.nvim_win_set_option(win, 'wrap', true)
  vim.api.nvim_win_set_option(win, 'linebreak', true)
  vim.api.nvim_win_set_option(win, 'number', true)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)

  return buf, win
end

local tutorial_content = {
  "╔══════════════════════════════════════════════════════════╗",
  "║                   Linux CLI Tutor                         ║",
  "╚══════════════════════════════════════════════════════════╝",
  "",
  "📚 Press ENTER to navigate sections • Press q to quit",
  "────────────────────────────────────────────────────────────",
  "",
  "SECTION 1: NAVIGATION",
  "────────────────────",
  "• pwd           - Print Working Directory",
  "• ls            - List directory contents",
  "  - ls -l       - Long format (detailed)",
  "  - ls -a       - Show hidden files",
  "• cd [dir]      - Change directory",
  "  - cd ~        - Go to home directory",
  "  - cd ..       - Go up one directory",
  "  - cd -        - Go to previous directory",
  "",
  "SECTION 2: FILE OPERATIONS",
  "─────────────────────────",
  "• cp <src> <dest>       - Copy file/directory",
  "• mv <src> <dest>       - Move/rename file/directory",
  "• rm <file>             - Remove file",
  "  - rm -r <dir>         - Remove directory recursively",
  "  - rm -f <file>        - Force remove (no confirmation)",
  "• mkdir <name>          - Create directory",
  "• touch <file>          - Create empty file",
  "",
  "SECTION 3: FILE VIEWING",
  "───────────────────────",
  "• cat <file>            - Concatenate and display files",
  "• less <file>           - View file with pagination",
  "• head <file>           - Show first 10 lines",
  "  - head -n 20 <file>   - Show first 20 lines",
  "• tail <file>           - Show last 10 lines",
  "  - tail -f <file>      - Follow file (watch changes)",
  "",
  "SECTION 4: PERMISSIONS",
  "─────────────────────",
  "• chmod <mode> <file>   - Change file permissions",
  "  Examples:",
  "  - chmod 755 file      - rwxr-xr-x (owner:rwx, group:rx, others:rx)",
  "  - chmod +x file       - Add execute permission",
  "• chown <user>:<group> <file> - Change owner/group",
  "",
  "SECTION 5: PROCESS MANAGEMENT",
  "───────────────────────────",
  "• ps aux                 - List all processes",
  "• top / htop             - Interactive process viewer",
  "• kill <PID>             - Terminate process",
  "• kill -9 <PID>          - Force kill process",
  "• jobs                   - List background jobs",
  "• fg                     - Bring job to foreground",
  "• bg                     - Continue job in background",
  "",
  "SECTION 6: TEXT PROCESSING",
  "────────────────────────",
  "• grep <pattern> <file> - Search text in files",
  "  - grep -r <pattern>   - Recursive search",
  "  - grep -i <pattern>   - Case-insensitive",
  "• sed 's/find/replace/' - Stream editor",
  "• awk '{print $1}'      - Text processing language",
  "• wc <file>             - Word count",
  "  - wc -l              - Line count",
  "  - wc -w              - Word count",
  "",
  "SECTION 7: NETWORKING",
  "────────────────────",
  "• ping <host>           - Test network connectivity",
  "• curl <url>            - Transfer data from URLs",
  "• wget <url>            - Download files",
  "• ssh <user@host>       - Secure shell",
  "• scp <file> <user@host>:<path> - Secure copy",
  "• netstat -tulpn        - Network connections",
  "",
  "SECTION 8: SYSTEM INFO",
  "─────────────────────",
  "• df -h                 - Disk space usage",
  "• du -sh <dir>          - Directory size",
  "• free -h               - Memory usage",
  "• uptime                - System uptime",
  "• uname -a              - System information",
  "• whoami                - Current user",
  "",
  "SECTION 9: PACKAGE MANAGEMENT",
  "────────────────────────────",
  "APT (Debian/Ubuntu):",
  "• sudo apt update       - Update package list",
  "• sudo apt upgrade      - Upgrade packages",
  "• sudo apt install <pkg> - Install package",
  "• sudo apt remove <pkg>  - Remove package",
  "",
  "YUM/DNF (RHEL/Fedora):",
  "• sudo dnf install <pkg> - Install package",
  "• sudo dnf remove <pkg>  - Remove package",
  "• sudo dnf update        - Update packages",
  "",
  "Pacman (Arch):",
  "• sudo pacman -S <pkg>   - Install package",
  "• sudo pacman -R <pkg>   - Remove package",
  "• sudo pacman -Syu       - Update system",
  "",
  "SECTION 10: USEFUL TIPS",
  "──────────────────────",
  "• Ctrl+C                - Cancel/terminate command",
  "• Ctrl+Z                - Suspend process",
  "• Ctrl+D                - End of file / Exit shell",
  "• Ctrl+L                - Clear screen",
  "• Tab                   - Auto-completion",
  "• Up/Down arrows        - Command history",
  "• !!                    - Repeat last command",
  "• !<num>                - Execute command from history",
  "• command1 && command2  - Run command2 if command1 succeeds",
  "• command1 || command2  - Run command2 if command1 fails",
  "• command > file        - Redirect output to file",
  "• command >> file       - Append output to file",
  "• command1 | command2   - Pipe output",
  "",
  "────────────────────────────────────────────────────────────",
  "💡 Practice these commands in your terminal!",
  "📖 For more info: man <command>  # e.g., 'man ls'",
  "❌ Press 'q' to close this tutorial",
}

local interactive_sections = {
  navigation = {
    title = "Navigation Commands",
    commands = {
      "pwd",
      "ls",
      "ls -l",
      "ls -a",
      "cd ~",
      "cd ..",
      "cd -",
    },
    description = "Basic directory navigation commands"
  },
  files = {
    title = "File Operations",
    commands = {
      "touch newfile.txt",
      "mkdir newdir",
      "cp newfile.txt copy.txt",
      "mv copy.txt renamed.txt",
      "rm renamed.txt",
      "rmdir newdir",
    },
    description = "Creating, copying, moving, and deleting files"
  },
  text = {
    title = "Text Processing",
    commands = {
      "echo 'Hello World' > test.txt",
      "cat test.txt",
      "grep 'Hello' test.txt",
      "wc -l test.txt",
      "head -n 5 test.txt",
      "tail -n 5 test.txt",
    },
    description = "Working with text files"
  }
}

local function set_keymaps(buf, win)
  -- Navigation keymaps
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', '<ESC>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })

  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_get_current_line()
    if line:match("^SECTION") then
      vim.cmd("normal! zz")
    end
  end, { buffer = buf })

  vim.keymap.set('n', 'gg', 'gg', { buffer = buf })
  vim.keymap.set('n', 'G', 'G', { buffer = buf })

  -- Search for sections
  vim.keymap.set('n', '/', function()
    vim.cmd("normal! /SECTION\\|COMMAND\\|TIP\\|NOTE")
  end, { buffer = buf })
end

local function apply_syntax_highlighting(buf)
  -- Clear existing syntax
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("syntax clear")
  end)

  -- Define syntax groups
  vim.api.nvim_buf_call(buf, function()
    -- Titles
    vim.cmd("syntax match LinuxTutorTitle '^╔.*╗$'")
    vim.cmd("syntax match LinuxTutorTitle '^║.*║$'")
    vim.cmd("syntax match LinuxTutorTitle '^╚.*╝$'")
    vim.cmd("syntax match LinuxTutorTitle '^SECTION.*$'")
    vim.cmd("syntax match LinuxTutorTitle '^────────────────[─]*$'")

    -- Commands
    vim.cmd("syntax match LinuxTutorCommand '^• .*$'")
    vim.cmd("syntax match LinuxTutorCommand '^  - .*$'")
    vim.cmd("syntax match LinuxTutorCommand '^  • .*$'")

    -- Highlight specific commands
    vim.cmd("syntax match LinuxTutorImportant '\\<sudo\\>'")
    vim.cmd("syntax match LinuxTutorImportant '\\<Ctrl\\+[A-Z]\\>'")
    vim.cmd("syntax match LinuxTutorImportant '\\<man\\>'")

    -- Package managers
    vim.cmd("syntax match LinuxTutorPackage 'APT.*:'")
    vim.cmd("syntax match LinuxTutorPackage 'YUM/DNF.*:'")
    vim.cmd("syntax match LinuxTutorPackage 'Pacman.*:'")

    -- Tips and notes
    vim.cmd("syntax match LinuxTutorTip '^💡.*$'")
    vim.cmd("syntax match LinuxTutorTip '^📖.*$'")
    vim.cmd("syntax match LinuxTutorTip '^❌.*$'")
    vim.cmd("syntax match LinuxTutorTip '^📚.*$'")
    vim.cmd("syntax match LinuxTutorTip '^⚡.*$'")

    -- Set highlight groups
    vim.cmd("highlight LinuxTutorTitle guifg=#89b4fa gui=bold")
    vim.cmd("highlight LinuxTutorCommand guifg=#a6e3a1")
    vim.cmd("highlight LinuxTutorImportant guifg=#f38ba8 gui=bold")
    vim.cmd("highlight LinuxTutorPackage guifg=#f9e2af")
    vim.cmd("highlight LinuxTutorTip guifg=#74c7ec gui=italic")
  end)
end

function M.setup(opts)
  opts = opts or {}

  -- Create window and buffer
  local buf, win = create_window()

  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, tutorial_content)

  -- Make buffer read-only but allow navigation
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)
  vim.api.nvim_buf_set_name(buf, 'LinuxTutor')

  -- Set filetype for potential future syntax highlighting
  vim.api.nvim_buf_set_option(buf, 'filetype', 'linuxtutor')

  -- Apply custom syntax highlighting
  apply_syntax_highlighting(buf)

  -- Set keymaps
  set_keymaps(buf, win)

  -- Set cursor at the beginning
  vim.api.nvim_win_set_cursor(win, {1, 0})

  -- Auto-commands for cleanup
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  })
end

-- Optional: Add a command to start interactive practice
function M.practice(section)
  print("Practice mode would open terminal for: " .. (section or "navigation"))
  -- This could be extended to open terminal windows with practice exercises
end

-- Optional: Quick reference function
function M.quick_ref()
  local quick = {
    "Quick Reference:",
    "ls -la          List all files detailed",
    "grep -r 'text' .   Recursive text search",
    "find . -name '*.txt'   Find files by name",
    "tar -czf archive.tar.gz dir/  Create tarball",
    "tar -xzf archive.tar.gz       Extract tarball",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = 50,
    height = #quick + 2,
    row = 1,
    col = 0,
    style = 'minimal',
    border = 'single',
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, quick)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

-- Add user commands when setup is called
function M.create_commands()
  vim.api.nvim_create_user_command('LinuxTutor', function()
    M.setup()
  end, { desc = 'Open Linux CLI tutorial' })

  vim.api.nvim_create_user_command('LinuxQuickRef', function()
    M.quick_ref()
  end, { desc = 'Show Linux quick reference' })
end

-- Optional: Setup with default keymaps
function M.setup_with_keymaps(opts)
  M.setup(opts)
  M.create_commands()

  -- Set default keymap if not disabled
  if not opts or not opts.disable_default_keymap then
    vim.keymap.set('n', '<leader>lt', ':LinuxTutor<CR>', { desc = 'Open Linux Tutor' })
    vim.keymap.set('n', '<leader>lq', ':LinuxQuickRef<CR>', { desc = 'Linux Quick Reference' })
  end
end

return M
