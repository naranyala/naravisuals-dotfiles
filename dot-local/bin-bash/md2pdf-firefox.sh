#!/usr/bin/env bash
# md-to-pdf — Convert Markdown files to PDF using pandoc and Chrome headless
# Supports batch conversion with glob patterns like "./**/*.md", "./*.md"
# Outputs PDFs alongside input files, preserving directory structure.

set -Eeuo pipefail

# Color output for better UX
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Default CSS for better Markdown rendering
DEFAULT_CSS='
body { font-family: Arial, sans-serif; line-height: 1.6; margin: 2cm; }
h1, h2, h3, h4, h5, h6 { margin-bottom: 0.5em; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
code, pre { font-family: monospace; background: #f5f5f5; padding: 2px 4px; border-radius: 4px; }
pre { padding: 1em; overflow-x: auto; }
img { max-width: 100%; height: auto; }
'

# Usage function
usage() {
    cat >&2 <<EOF
Usage: ${0##*/} [options] <file.md|pattern> [more patterns...]

Convert Markdown files to PDF using pandoc and Chrome headless mode.
Outputs PDFs alongside input files, preserving directory structure.

Options:
  -h, --help            Show this help message
  -c, --css <file>      Use custom CSS file for styling (default: basic Markdown styling)
  -f, --flavor <flavor> Markdown flavor for pandoc (e.g., github, commonmark, markdown; default: github)
  -d, --debug           Keep temporary HTML files for debugging

Examples:
  ${0##*/} ./README.md
  ${0##*/} ./*.md ./docs/**/*.md
  ${0##*/} "**/*.md"  # Convert all .md files recursively
  ${0##*/} -c style.css -f commonmark ./README.md
  ${0##*/} -d ./README.md  # Debug mode

Requirements:
  - pandoc (for Markdown to HTML conversion)
  - google-chrome or chromium (for HTML to PDF conversion)
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
    if [[ "$debug_mode" != "true" && -n "${tmp_html:-}" && -f "$tmp_html" ]]; then
        rm -f "$tmp_html"
    fi
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Parse options
css_file=""
flavor="github"
debug_mode="false"
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
        -f|--flavor)
            flavor="$2"
            shift 2
            ;;
        -d|--debug)
            debug_mode="true"
            shift
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
if command -v google-chrome >/dev/null 2>&1; then
    CHROME_CMD="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
    CHROME_CMD="chromium"
else
    error_exit "google-chrome or chromium is required but not installed. See https://www.google.com/chrome/ or https://www.chromium.org/"
fi

# Validate CSS file if provided
if [[ -n "$css_file" ]]; then
    [[ -f "$css_file" ]] || error_exit "CSS file not found: $css_file"
    css_content=$(cat "$css_file" 2>/dev/null) || error_exit "Failed to read CSS file: $css_file"
else
    css_content="$DEFAULT_CSS"
fi

# Validate Markdown flavor
case "$flavor" in
    github|commonmark|markdown|markdown_strict|gfm)
        pandoc_flavor="markdown+$flavor+pipe_tables+raw_html"
        ;;
    *)
        error_exit "Invalid Markdown flavor: $flavor. Use github, commonmark, markdown, markdown_strict, or gfm."
        ;;
esac

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

        # Validate file readability and non-empty content
        [[ -r "$file" ]] || {
            warn_msg "File is not readable: $file"
            continue
        }
        [[ -s "$file" ]] || {
            warn_msg "File is empty: $file"
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
            [[ "$debug_mode" != "true" ]] && rm -f "$tmp_html"
            continue
        }

        # Step 1: Convert Markdown to HTML using pandoc
        if ! pandoc "$file" \
            -o "$tmp_html" \
            --from="$pandoc_flavor" \
            --self-contained \
            --standalone \
            --metadata title="$(basename "${file%.md}")" \
            --css="<style>$css_content</style>" 2>"${tmp_html}.pandoc.log"; then
            warn_msg "Pandoc conversion failed for: $file (see ${tmp_html}.pandoc.log for details)"
            failed_conversions+=1
            [[ "$debug_mode" != "true" ]] && rm -f "$tmp_html"
            continue
        fi

        # Validate HTML file
        [[ -s "$tmp_html" ]] || {
            warn_msg "Generated HTML is empty for: $file"
            failed_conversions+=1
            [[ "$debug_mode" != "true" ]] && rm -f "$tmp_html"
            continue
        }

        # Step 2: Convert HTML to PDF using Chrome headless
        chrome_cmd=("$CHROME_CMD" --headless --disable-gpu --no-sandbox --no-margins --disable-web-security --print-to-pdf="$out_file" "file://$(realpath "$tmp_html")")
        if "${chrome_cmd[@]}" 2>"${tmp_html}.chrome.log"; then
            if [[ -f "$out_file" && -s "$out_file" ]]; then
                success_msg "✅ Successfully converted: $file"
                successful_conversions+=1
            else
                warn_msg "PDF creation failed or empty file: $out_file (see ${tmp_html}.chrome.log for details)"
                failed_conversions+=1
                [[ -f "$out_file" ]] && rm -f "$out_file"
            fi
        else
            warn_msg "Chrome conversion failed for: $file (see ${tmp_html}.chrome.log for details)"
            failed_conversions+=1
        fi

        [[ "$debug_mode" != "true" ]] && rm -f "$tmp_html" "${tmp_html}.pandoc.log" "${tmp_html}.chrome.log"
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
