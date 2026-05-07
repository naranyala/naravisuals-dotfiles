
#!/bin/bash
set -e

echo "=== Python → Single Executable Builder ==="

# ===== Prompt with defaults =====
read -p "Python entry file [main.py]: " PYTHON_ENTRY
PYTHON_ENTRY=${PYTHON_ENTRY:-main.py}

read -p "Executable name [myapp]: " APP_NAME
APP_NAME=${APP_NAME:-myapp}

read -p "Console app? (y/N): " CONSOLE_APP
CONSOLE_APP=${CONSOLE_APP:-N}

# ===== Verify entry file =====
if [[ ! -f "$PYTHON_ENTRY" ]]; then
    echo "ERROR: File '$PYTHON_ENTRY' not found!"
    exit 1
fi

# ===== Install pyinstaller if missing =====
if ! command -v pyinstaller &>/dev/null; then
    echo "PyInstaller not found. Installing..."
    pip install pyinstaller
fi

# ===== Clean old builds =====
echo "=== Cleaning old builds ==="
rm -rf build dist *.spec

# ===== Build command =====
if [[ "$CONSOLE_APP" =~ ^[Yy]$ ]]; then
    echo "=== Building console executable ==="
    pyinstaller --onefile --name "$APP_NAME" "$PYTHON_ENTRY"
else
    echo "=== Building GUI executable ==="
    pyinstaller --onefile --windowed --name "$APP_NAME" "$PYTHON_ENTRY"
fi

# ===== Result =====
if [[ -f "dist/$APP_NAME" ]]; then
    echo "=== Build complete! ==="
    echo "Executable: dist/$APP_NAME"
else
    echo "ERROR: Build failed."
    exit 1
fi
