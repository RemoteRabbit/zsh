#!/usr/bin/env bash
# Auto-documentation generator for zsh configuration
# Parses alias files and generates FUNCTIONS.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ALIAS_DIR="$REPO_DIR/alias"
OUTPUT_FILE="$REPO_DIR/FUNCTIONS.md"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Generating documentation from code...${NC}"

# Initialize output file
cat > "$OUTPUT_FILE" << 'EOF'
# 🔧 Function Reference

Auto-generated documentation of all custom functions and aliases.

---

EOF

# Function to extract and document functions from a file
document_file() {
    local file="$1"
    local category; category="$(basename "$file")"
    local category_name=""

    # Map filenames to friendly names
    case "$category" in
        core) category_name="Core Utilities" ;;
        git) category_name="Git Integration" ;;
        navigation) category_name="Navigation & Directory Management" ;;
        productivity) category_name="Productivity Tools" ;;
        fzf-enhancements) category_name="FZF Enhanced Functions" ;;
        benchmark) category_name="Performance Benchmarking" ;;
        help) category_name="Help & Documentation" ;;
        *) category_name="$category" ;;
    esac

    echo -e "${GREEN}  Processing: $category_name${NC}"

    # Add category header
    cat >> "$OUTPUT_FILE" << EOF

## $category_name

EOF

    # Track if we found any functions
    local found_functions=0

    # Parse the file for functions and their comments
    local in_function=0
    local func_name=""
    local func_comment=""
    local func_body=""

    while IFS= read -r line; do
        # Check for function definition
        if [[ $line =~ ^([a-zA-Z0-9_-]+)\(\)[[:space:]]*\{ ]]; then
            func_name="${BASH_REMATCH[1]}"
            in_function=1
            func_body="$line"
            found_functions=1

        # Check for closing brace (simple heuristic)
        elif [[ $in_function -eq 1 ]]; then
            func_body="$func_body"$'\n'"$line"

            # If we hit a closing brace at the start of the line, end function
            if [[ $line =~ ^\} ]]; then
                # Extract usage from function body if it echoes "Usage:"
                local usage; usage=$(echo "$func_body" | grep -o 'Usage: [^"]*' | head -1 || echo "")

                # Write function documentation
                cat >> "$OUTPUT_FILE" << EOF
### \`$func_name\`

EOF

                if [[ -n "$func_comment" ]]; then
                    echo "$func_comment" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi

                if [[ -n "$usage" ]]; then
                    echo "**$usage**" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi

                # Extract first meaningful comment from body
                local description; description=$(echo "$func_body" | grep -E '^\s*#' | grep -v '^\s*#!/' | head -1 | sed 's/^\s*#\s*//' || echo "")
                if [[ -n "$description" && -z "$func_comment" ]]; then
                    echo "$description" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi

                # Reset state
                in_function=0
                func_name=""
                func_comment=""
                func_body=""
            fi
        fi

        # Capture comment before function
        if [[ $line =~ ^#[[:space:]](.+) ]] && [[ $in_function -eq 0 ]]; then
            local comment="${BASH_REMATCH[1]}"
            # Skip shebang and section separators
            if [[ ! $comment =~ ^!/|^=+|^-+ ]]; then
                func_comment="$comment"
            fi
        elif [[ ! $line =~ ^# ]] && [[ $in_function -eq 0 ]]; then
            # Reset comment if we hit a non-comment, non-function line
            if [[ ! $line =~ ^[[:space:]]*$ ]]; then
                func_comment=""
            fi
        fi

    done < "$file"

    # Document aliases in the file
    local aliases; aliases=$(grep "^alias " "$file" | sed 's/alias //' | sed 's/=/ = /' || echo "")

    if [[ -n "$aliases" ]]; then
        if [[ $found_functions -eq 1 ]]; then
            echo "" >> "$OUTPUT_FILE"
        fi

        cat >> "$OUTPUT_FILE" << EOF
### Aliases

\`\`\`bash
$aliases
\`\`\`

EOF
    fi

    if [[ $found_functions -eq 0 ]] && [[ -z "$aliases" ]]; then
        echo "*No functions or aliases found in this category.*" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

# Process all alias files
if [[ -d "$ALIAS_DIR" ]]; then
    for file in "$ALIAS_DIR"/*; do
        if [[ -f "$file" ]]; then
            document_file "$file"
        fi
    done
else
    echo "Error: Alias directory not found: $ALIAS_DIR"
    exit 1
fi

# Add keybindings section
if [[ -f "$REPO_DIR/keybindings.zsh" ]]; then
    echo -e "${GREEN}  Processing: Keybindings${NC}"

    cat >> "$OUTPUT_FILE" << 'EOF'

## ⌨️ Keybindings

Custom keyboard shortcuts configured in `keybindings.zsh`.

### Vi Mode Navigation
- `H` - Beginning of line (command mode)
- `L` - End of line (command mode)
- `K` - History search backward (command mode)
- `J` - History search forward (command mode)
- `jj`, `jk` - Exit insert mode

### Command Line Editing
- `Ctrl+E` - Edit command in editor
- `Ctrl+U` - Delete from cursor to beginning of line
- `Ctrl+K` - Delete from cursor to end of line
- `Ctrl+W` - Delete word backward
- `Ctrl+Y` - Accept autosuggestion

### FZF Integration
- `Ctrl+F` - Quick file finder
- `Ctrl+J` - Quick directory jumper
- `Ctrl+G` - Start content search
- `Ctrl+R` - History search

### Utilities
- `Alt+R` - Reload zsh configuration
- `Ctrl+S Ctrl+U` - Insert sudo at line start
- `Ctrl+L` - Clear screen

EOF
fi

# Add footer
cat >> "$OUTPUT_FILE" << 'EOF'

---

## 📝 Notes

- This documentation is auto-generated from inline comments and function definitions
- Run `./scripts/shell/generate-docs.sh` to regenerate
- For interactive help, use `zsh-help` command
- For quick function lookup, use `list-functions` command

EOF

echo -e "${GREEN}✅ Documentation generated: $OUTPUT_FILE${NC}"
echo -e "${BLUE}📄 Functions documented from $(find "$ALIAS_DIR" -type f | wc -l) files${NC}"
