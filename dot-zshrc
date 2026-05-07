export ZSH="/home/naranyala/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z sudo command-not-found colored-man-pages history-substring-search web-search dirhistory zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab)
source $ZSH/oh-my-zsh.sh

# Load custom plugins manually if needed
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# bun completions
[ -s "/home/naranyala/.bun/_bun" ] && source "/home/naranyala/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# if [ -f ~/.bashrc ]; then
#   source ~/.bashrc
# fi
#

eval "$($HOME/.linuxbrew/bin/brew shellenv)"

. "$HOME/.cargo/env"   

export PATH="/run/media/naranyala/Data/diskd-binaries/flutter/bin:$PATH"


