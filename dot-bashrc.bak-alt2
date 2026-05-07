
# WELCOME

# export PATH="/c/D/dmd2/windows/bin64:$PATH"
# export PATH="/c/D/dmd2/windows/bin:$PATH"
export PATH="~/.bun/bin:$PATH"
export PATH="/d/projects-remote/naranyala-dotfiles/.local/bin-c99:$PATH"
export PATH="/d/projects-remote/naranyala-dotfiles/packages/cli_md2pdf/target/debug:$PATH"
export PATH="/d/projects-remote/naranyala-dotfiles/packages/cli_mergepdf/target/debug:$PATH"
export PATH="/c/Users/Administrator/.opencode/bin:$PATH"
export PATH="/c/Users//Administrator/.bun/bin:$PATH"
# export PATH="/d/diskd-binaries/ldc2-1.41.0-windows-x64\bin:$PATH"
export PATH="/d/diskd-binaries/c3-windows:$PATH"
export PATH="/d/diskd-binaries/v_windows:$PATH"
export PATH="/d/diskd-binaries/odin-windows:$PATH"
export PATH="/d/diskd-binaries/w64devkit:$PATH"
# export PATH="/d/diskd-binaries/tinycc:$PATH"
export PATH="/d/diskd-binaries/vala-prebuilt:$PATH"
export PATH="$VCPKG_ROOT:$PATH"
export PATH="/c/Users/Administrator/.local/bin:$PATH"
export PATH="$PATH:/c/Program Files/dotnet"
export PATH="/c/ProgramData/chocolatey/bin:$PATH"
export PATH="/d/projects-remote/exploration-umka-libffi/vendor/umka-lang/editors:$PATH"

export VCPKG_ROOT="/c/Tools/vcpkg"
# export PATH="/c/Program\ Files/CMake/bin:$PATH"


CURRENT_LANG="c_code"
# CURRENT_LANG="crust_code"
# CURRENT_LANG="czig_code"
# CURRENT_LANG="c3_code"

build_output=""
# extention=""
extention=".exe"

if [ "$CURRENT_LANG" = "c_code" ]; then
    build_output="/_bin"
elif [ "$CURRENT_LANG" = "crust_code" ]; then
    build_output="/_bin/debug"
elif [ "$CURRENT_LANG" = "czig_code" ]; then
    build_output="/_bin"
elif [ "$CURRENT_LANG" = "c3_code" ]; then
    build_output=""
fi

export PATH="/d/projects-remote/naranyala-dotfiles/packages/$CURRENT_LANG:$PATH"
export PATH="/d/projects-remote/naranyala-dotfiles/packages/$CURRENT_LANG$build_output:$PATH"
# alias dirnav="/d/projects-remote/naranyala-dotfiles/packages/$CURRENT_LANG$build_output/dirnav$extention"

# /d/projects-remote/naranyala-dotfiles/packages/czig_code/dirnav/zig-out/bin/dirnav.exe

# alias goto-1="cd $(dirnav --nav 0)"
# alias goto-2="cd $(dirnav --nav 1)"
# alias goto-3="cd $(dirnav --nav 2)"
# alias goto-4="cd $(dirnav --nav 3)"


# alias mergepdf="bun /d/diskd-scripts/javascript/merge-all-pdf-in-specific-dir.js"
# alias cmake="/c/Program\ Files/CMake/bin/cmake.exe"
# alias w64devkit="/d/diskd-binaries/w64devkit/w64devkit.exe"

alias mergepdf-cwd="bun /d/diskd-scripts/javascript/merge-all-pdf-in-current-dir.js"
alias win-foxitpdf="/c/Program\ Files\ \(x86\)/Foxit\ Software/Foxit\ PDF\ Reader/FoxitPDFReader.exe"
alias win-windirstat="/c/Program\ Files/WinDirStat/WinDirStat.exe"
alias win-pdfxcview="/c/Program\ Files/Tracker\ Software/PDF\ Viewer/PDFXCview.exe"
alias win-sumatrapdf="/c/Users/Administrator/AppData/Local/SumatraPDF/SumatraPDF.exe"
alias edit-ps-profile="nvim /c/Users/Administrator/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
alias win-term-new="wt -w 0  new-tab -p $(pwd)"
alias vcpkg="/c/Users/Administrator/vcpkg/vcpkg.exe"
