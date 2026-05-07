#!/usr/bin/env bash
# md-to-pdf — Convert Markdown files to PDF using pandoc and Firefox headless
# Supports batch conversion with glob patterns like "./**/*.md", "./*.md"
# Outputs PDFs alongside input files, preserving directory structure.

set -Eeuo pipefail

# Color output for better UX
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Default CSS for HTML rendering
DEFAULT_CSS='body{font-family:Arial,sans-serif;line-height:1.6;margin:2cm;}'

# Usage function
usage() {
    cat >&2 <<EOF
Usage: ${0##*/} [options] <file.md|pattern> [more patterns...]

Convert Markdown files to PDF using pandoc and Firefox headless mode.
Outputs PDFs alongside input files, preserving directory structure.

Options:
  -h, --help        Show this help message
  -c, --css <file>  Use custom CSS file for styling (default: basic Arial styling)

Examples:
  ${0##*/} ./README.md
  ${0##*/} ./*.md ./docs/**/*.md
  ${0##*/} "**/*.md"  # Convert all .md files recursively
  ${0##*/} -c style.css ./README.md

Requirements:
  - pandoc (for Markdown to HTML conversion)
  - firefox (for HTML to PDF conversion)
EOF
}

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message function
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Warning message function
warn_msg() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Cleanup function for temporary files
cleanup() {
    local exit_code=$?
    [[ -n "${tmp_html:-}" && -f "$tmp_html" ]] && rm -f "$tmp_html"
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Parse options
css_file=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--css)
            css_file="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Validate arguments
[[ $# -eq 0 ]] && { usage; exit 1; }

# Validate required tools
command -v pandoc >/dev/null 2>&1 || error_exit "pandoc is required but not installed. See https://pandoc.org/installing.html"
command -v firefox >/dev/null 2>&1 || error_exit "firefox is required but not installed"

# Validate CSS file if provided
if [[ -n "$css_file" ]]; then
    [[ -f "$css_file" ]] || error_exit "CSS file not found: $css_file"
    css_content=$(cat "$css_file")
else
    css_content="$DEFAULT_CSS"
fi

# Enable recursive globbing and null globbing
shopt -s globstar nullglob

# Track conversion statistics
declare -i total_files=0 successful_conversions=0 failed_conversions=0

# Process each pattern
for pattern in "$@"; do
    echo "Processing pattern: $pattern"
    files_found=0

    # Use find for robust glob handling
    while IFS= read -r -d '' file; do
        files_found=1
        [[ -f "$file" && "$file" =~ \.md$ ]] || {
            warn_msg "Skipping non-markdown file: $file"
            continue
        }

        total_files+=1
        out_file="${file%.md}.pdf"
        out_dir="$(dirname "$out_file")"
        tmp_html=$(mktemp --suffix=.html) || error_exit "Failed to create temporary file"

        echo "Converting: $file → $out_file"

        # Create output directory
        mkdir -p "$out_dir" 2>/dev/null || {
            warn_msg "Failed to create directory: $out_dir (skipping $file)"
            failed_conversions+=1
            rm -f "$tmp_html"
            continue
        }

        # Step 1: Convert Markdown to HTML using pandoc
        if ! pandoc "$file" \
            -o "$tmp_html" \
            --standalone \
            --metadata title="$(basename "${file%.md}")" \
            --css="<style>$css_content</style>" 2>/dev/null; then
            warn_msg "Pandoc conversion failed for: $file"
            failed_conversions+=1
            rm -f "$tmp_html"
            continue
        fi

        # Step 2: Convert HTML to PDF using Firefox
        firefox_cmd=(firefox --headless "--print-to-pdf=$out_file" "file://$PWD/$tmp_html")
        if "${firefox_cmd[@]}" 2>/dev/null; then
            if [[ -f "$out_file" && -s "$out_file" ]]; then
                success_msg "✅ Successfully converted: $file"
                successful_conversions+=1
            else
                warn_msg "PDF creation failed or empty file: $out_file"
                failed_conversions+=1
                [[ -f "$out_file" ]] && rm -f "$out_file"
            fi
        else
            warn_msg "Firefox conversion failed for: $file"
            failed_conversions+=1
        fi

        rm -f "$tmp_html"
        tmp_html=""
    done < <(find . -path "$pattern" -type f -print0 2>/dev/null || printf '%s\0' "$pattern" 2>/dev/null)

    [[ $files_found -eq 0 ]] && warn_msg "No files found matching pattern: $pattern"
done

# Print summary
echo
echo "=== Conversion Summary ==="
echo "Total files processed: $total_files"
success_msg "Successful conversions: $successful_conversions"
[[ $failed_conversions -gt 0 ]] && warn_msg "Failed conversions: $failed_conversions"

if [[ $successful_conversions -eq $total_files && $total_files -gt 0 ]]; then
    success_msg "🎉 All conversions completed successfully!"
    exit 0
elif [[ $successful_conversions -gt 0 ]]; then
    exit 1  # Partial success
else
    error_exit "No files were successfully converted"
fi
