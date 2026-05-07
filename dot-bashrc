#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

alias goto-remote="cd /run/media/naranyala/Data/projects-remote"
alias goto-agentic="cd /run/media/naranyala/Data/projects-agentic"
alias goto-diskd-bin="cd /run/media/naranyala/Data/diskd-binaries"

# opencode
export PATH=/home/naranyala/.opencode/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Run fastfetch on shell initialization
# fastfetch

export PATH="~/.bun/bin:$PATH"

alias mergepdf-cwd="bun /run/media/naranyala/Data/diskd-scripts/javascript/merge-all-pdf-in-current-dir.js"

export PATH="/run/media/naranyala/Data/diskd-binaries/v_linux:$PATH"

alias restart-plasma="pkill plasmashell && plasmashell &"

export WASMTIME_HOME="$HOME/.wasmtime"

export PATH="$WASMTIME_HOME/bin:$PATH"

export PATH="/run/media/naranyala/Data/diskd-binaries/jule/jule/bin:$PATH"

alias sys-suspend="sudo /run/media/naranyala/Data/projects-remote/naravisuals-dotfiles/.local/bin-bash/force-suspend-linux.sh"

alias install-bun-runtime="curl -fsSL https://bun.sh/install | bash"
alias install-opencode="bun i -g opencode-ai@latest"
alias install-qwencode="bun install -g @qwen-code/qwen-code@latest"
alias install-gemini-cli="bun install -g @google/gemini-cli"
alias install-codex="bun install -g @openai/codex"
alias install-claude-code="curl -fsSL https://claude.ai/install.sh | bash"

alias install-rust-compiler="curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
alias install-rust-compiler2="sudo dnf install rust cargo"
