
import os
import re
import shutil
import subprocess
import platform

def get_ps_profile_path():
    shell = "pwsh" if shutil.which("pwsh") else "powershell.exe"
    try:
        cmd = [shell, "-NoProfile", "-Command", "$PROFILE"]
        return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout.strip()
    except:
        home = os.path.expanduser("~")
        return os.path.join(home, ".config" if platform.system() != "Windows" else "Documents", 
                            "powershell" if platform.system() != "Windows" else "PowerShell", 
                            "Microsoft.PowerShell_profile.ps1")

def convert_bashrc_to_ps(bashrc_path):
    ps_profile = get_ps_profile_path()
    if os.path.exists(ps_profile):
        shutil.copy2(ps_profile, f"{ps_profile}.bak")

    with open(bashrc_path, 'r') as f:
        lines = f.readlines()

    ps_content = [
        "\n# --- AUTO-GENERATED FROM BASHRC ---\n",
        "# Use '$IsWindows' or '$IsLinux' for platform-specific blocks if needed\n"
    ]

    # Parsing state for multi-line functions
    in_function = False
    func_name = ""
    func_body = []

    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith('#'): continue

        # 1. Handle Exports (Env Vars)
        export_match = re.match(r'^export\s+(\w+)=(.+)', stripped)
        if export_match:
            var, val = export_match.groups()
            val = val.strip("'\"").replace('$', '$env:')
            ps_content.append(f"$env:{var} = \"{val}\"\n")
            continue

        # 2. Handle Simple Aliases
        alias_match = re.match(r'^alias\s+(\w+)=[\'"](.+)[\'"]', stripped)
        if alias_match:
            name, cmd = alias_match.groups()
            # If alias has spaces/args, it must be a function in PS
            if " " in cmd:
                ps_content.append(f"function {name} {{ {cmd} @args }}\n")
            else:
                ps_content.append(f"Set-Alias -Name {name} -Value {cmd} -ErrorAction SilentlyContinue\n")
            continue

        # 3. Handle Functions (e.g., func_name() { ... })
        func_start = re.match(r'^(\w+)\s*\(\)\s*\{', stripped)
        if func_start:
            in_function = True
            func_name = func_start.group(1)
            continue
        
        if in_function:
            if stripped == "}":
                # Convert Bash args to PS args: $1 -> $args[0], $@ -> @args
                body = " ".join(func_body).replace('$1', '$args[0]').replace('$2', '$args[1]').replace('$@', '@args')
                ps_content.append(f"function {func_name} {{ {body} }}\n")
                in_function = False
                func_body = []
            else:
                func_body.append(stripped)

    os.makedirs(os.path.dirname(ps_profile), exist_ok=True)
    with open(ps_profile, 'a', encoding='utf-8') as f:
        f.writelines(ps_content)
    print(f"Update complete: {ps_profile}")

if __name__ == "__main__":
    target = next((os.path.expanduser(f) for f in ["~/.bashrc", "~/.bash_profile"] if os.path.exists(os.path.expanduser(f))), None)
    if target: convert_bashrc_to_ps(target)
