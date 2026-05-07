#!/bin/bash

JDK_VERSION=${1:-"17"}
VENDOR=${2:-"temurin"}
INSTALL_BASE="/opt/java"
PROFILE_FILE="/etc/profile.d/java.sh"

die() { echo "Error: $1" >&2; exit 1; }

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "x64" ;;
        aarch64) echo "aarch64" ;;
        arm64) echo "aarch64" ;;
        *) die "Unsupported architecture: $(uname -m)" ;;
    esac
}

fetch_temurin() {
    local version=$1 arch=$(detect_arch)
    local api_url="https://api.adoptium.net/v3/assets/feature_releases/${version}/ga?architecture=${arch}&image_type=jdk&os=linux&page=0&page_size=1"
    
    curl -sf "$api_url" | python3 -c "
import sys, json
data = json.load(sys.stdin)
binary = data[0]['binary']
print(f\"{binary['package']['link']}|{binary['package']['name']}\")
"
}

fetch_zulu() {
    local version=$1 arch=$(detect_arch)
    local api_url="https://api.azul.com/metadata/v1/zulu/packages/?java_version=${version}&os=linux&arch=${arch}&archive_type=tar.gz&java_package_type=jdk&latest=true&release_status=ga"
    
    curl -sf "$api_url" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data:
    pkg = data[0]
    print(f\"{pkg['download_url']}|{pkg['name']}.tar.gz\")
"
}

fetch_corretto() {
    local version=$1 arch=$(detect_arch)
    local arch_suffix="x64"
    [[ "$arch" == "aarch64" ]] && arch_suffix="aarch64"
    
    # Amazon Corretto direct download pattern
    local base_url="https://corretto.aws/downloads/latest"
    local filename="amazon-corretto-${version}-linux-${arch_suffix}.tar.gz"
    local download_url="${base_url}/${filename}"
    
    # Verify URL exists
    if curl -sf --head "$download_url" >/dev/null; then
        echo "${download_url}|${filename}"
    fi
}

fetch_liberica() {
    local version=$1 arch=$(detect_arch)
    local api_url="https://api.bell-sw.com/v1/liberica/releases?version-type=feature&version-feature=${version}&arch=${arch}&os=linux&package-type=jdk&bundle-type=jdk"
    
    curl -sf "$api_url" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data:
    pkg = data[0]
    print(f\"{pkg['downloadUrl']}|{pkg['filename']}\")
"
}

fetch_sapmachine() {
    local version=$1 arch=$(detect_arch)
    local api_url="https://api.github.com/repos/SAP/SapMachine/releases"
    
    curl -sf "$api_url" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
arch_map = {'x64': 'x64', 'aarch64': 'aarch64'}
target_arch = arch_map.get('${arch}', '${arch}')
version = '${version}'

for release in data:
    if f'sapmachine-{version}' in release['tag_name'].lower():
        for asset in release['assets']:
            if (asset['name'].endswith('.tar.gz') and 
                'linux' in asset['name'] and 
                target_arch in asset['name'] and
                'jdk' in asset['name']):
                print(f\"{asset['browser_download_url']}|{asset['name']}\")
                sys.exit(0)
"
}

fetch_microsoft() {
    local version=$1 arch=$(detect_arch)
    local api_url="https://api.github.com/repos/microsoft/openjdk/releases"
    
    curl -sf "$api_url" | python3 -c "
import sys, json
data = json.load(sys.stdin)
arch_map = {'x64': 'x64', 'aarch64': 'aarch64'}
target_arch = arch_map.get('${arch}', '${arch}')
version = '${version}'

for release in data:
    if f'{version}.' in release['tag_name']:
        for asset in release['assets']:
            if (asset['name'].endswith('.tar.gz') and 
                'linux' in asset['name'] and 
                target_arch in asset['name']):
                print(f\"{asset['browser_download_url']}|{asset['name']}\")
                sys.exit(0)
"
}

fetch_jdk_info() {
    local version=$1 vendor=$2
    
    case "$vendor" in
        temurin|adoptium) fetch_temurin "$version" ;;
        zulu|azul) fetch_zulu "$version" ;;
        corretto|amazon) fetch_corretto "$version" ;;
        liberica|bellsoft) fetch_liberica "$version" ;;
        sapmachine|sap) fetch_sapmachine "$version" ;;
        microsoft|ms) fetch_microsoft "$version" ;;
        *) die "Unknown vendor: $vendor. Supported: temurin, zulu, corretto, liberica, sapmachine, microsoft" ;;
    esac
}

install_jdk() {
    [[ $EUID -eq 0 ]] || die "Root privileges required"
    
    echo "Fetching JDK info for $VENDOR $JDK_VERSION..."
    local jdk_info=$(fetch_jdk_info "$JDK_VERSION" "$VENDOR")
    [[ -n "$jdk_info" ]] || die "Failed to fetch JDK info for $VENDOR $JDK_VERSION"
    
    local download_url=${jdk_info%|*}
    local archive_name=${jdk_info#*|}
    local jdk_name=${archive_name%.tar.gz}
    local install_path="$INSTALL_BASE/$jdk_name"
    
    echo "Installing $VENDOR OpenJDK $JDK_VERSION"
    echo "URL: $download_url"
    
    # Download and extract
    mkdir -p "$INSTALL_BASE"
    echo "Downloading and extracting..."
    curl -L "$download_url" | tar -xzf - -C "$INSTALL_BASE" || die "Download/extraction failed"
    
    # Handle different extraction patterns
    local extracted_dir=$(find "$INSTALL_BASE" -maxdepth 1 -name "*jdk*" -type d | head -1)
    if [[ "$extracted_dir" != "$install_path" && -d "$extracted_dir" ]]; then
        mv "$extracted_dir" "$install_path"
    fi
    
    # Set as system default
    cat > "$PROFILE_FILE" << EOF
export JAVA_HOME="$install_path"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
    
    # Register alternatives
    local priority=$((1000 + JDK_VERSION))
    for cmd in java javac jar; do
        [[ -f "$install_path/bin/$cmd" ]] && 
        update-alternatives --install "/usr/bin/$cmd" "$cmd" "$install_path/bin/$cmd" "$priority" --quiet
    done
    
    # Verify
    source "$PROFILE_FILE"
    "$install_path/bin/java" -version || die "Installation verification failed"
    
    echo "JDK $JDK_VERSION ($VENDOR) installed successfully at $install_path"
    echo "Reboot or run: source $PROFILE_FILE"
}

list_sources() {
    echo "Available JDK sources:"
    echo "  temurin    - Eclipse Temurin (Adoptium)"
    echo "  zulu       - Azul Zulu"
    echo "  corretto   - Amazon Corretto"
    echo "  liberica   - BellSoft Liberica"
    echo "  sapmachine - SAP Machine"
    echo "  microsoft  - Microsoft OpenJDK"
    echo ""
    echo "Usage: $0 [version] [vendor]"
    echo "Example: $0 17 zulu"
}

case "${1:-install}" in
    list) list_sources ;;
    remove) 
        [[ $EUID -eq 0 ]] || die "Root privileges required"
        rm -rf "$INSTALL_BASE" "$PROFILE_FILE"
        for cmd in java javac jar; do
            update-alternatives --remove-all "$cmd" 2>/dev/null || true
        done
        echo "Java installations removed"
        ;;
    help|--help|-h) list_sources ;;
    *) 
        # Check if first arg is a vendor name
        if [[ "$1" =~ ^(temurin|zulu|corretto|liberica|sapmachine|microsoft)$ ]]; then
            VENDOR="$1"
            JDK_VERSION="${2:-17}"
        fi
        install_jdk 
        ;;
esac
