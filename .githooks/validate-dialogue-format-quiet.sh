#!/bin/bash

# Quiet dialogue validation script for GitScrolls
# Only outputs errors, no verbose progress

ERRORS=0
ERROR_MESSAGES=""

# Add color support
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to add error message
add_error() {
    ERRORS=$((ERRORS + 1))
    ERROR_MESSAGES="${ERROR_MESSAGES}\n$1"
}

# Characters to check (expand as needed)
CHARACTERS="Tuxrates|Tuxicles|Linus|Prophet Nia|Fork-Bearer|Elena|The Trickster|TempleSentinel|Ghost Developer|Damned Developer|Force Push Demon|CI/CD Serpent|Eternal Rebaser|Rebase Demon"

# Check only git-tracked scroll files
for file in $(git ls-files 'scrolls/*.md'); do
    if [ -f "$file" ]; then
        # Check 1: Character names should be bold (__Character__)
        # Look for lines that have "Name:" pattern but the name is not bold
        NAME_CHECK=""
        # Check for any word followed by colon at start of line (potential dialogue)
        while IFS= read -r line_data; do
            line_num=$(echo "$line_data" | cut -d: -f1)
            line_content=$(echo "$line_data" | cut -d: -f2-)
            
            # Extract the character name (word before the colon)
            char_name=$(echo "$line_content" | grep -o "^[A-Za-z][A-Za-z]*:")
            if [ -n "$char_name" ]; then
                # Check if this character name is in our known list
                name_without_colon=$(echo "$char_name" | sed 's/:$//')
                if echo "$name_without_colon" | grep -qE "^(${CHARACTERS})$"; then
                    NAME_CHECK="${NAME_CHECK}${line_num}:${line_content}\n"
                fi
            fi
        done < <(grep -n "^[A-Za-z].*:" "$file")
        
        if [ -n "$NAME_CHECK" ]; then
            echo -e "$NAME_CHECK" | while IFS= read -r line; do
                [ -n "$line" ] && add_error "❌ $file:$line - Character name should be bold: __Character__:"
            done
        fi
        
        # Check 2: CHRONICLER sections should NOT use character dialogue format
        CHRONICLER_CHECK=$(grep -n "^__CHRONICLER__:" "$file" 2>/dev/null || true)
        if [ -n "$CHRONICLER_CHECK" ]; then
            add_error "❌ $file: CHRONICLER should not use character dialogue format:\n$CHRONICLER_CHECK"
        fi
        
        # Check 3: Check for common formatting mistakes
        MISTAKE_COUNT=0
        
        # Space before colon
        SPACE_CHECK=$(grep -n "^__.*__ :" "$file" 2>/dev/null || true)
        if [ -n "$SPACE_CHECK" ]; then
            ((MISTAKE_COUNT++))
            while IFS= read -r line; do
                add_error "❌ $file:$line - Remove space before colon"
            done <<< "$SPACE_CHECK"
        fi
        
        # Missing colon - check for dialogue patterns without colon
        # Look for: __Name__ "dialogue" but NOT __Name__: "dialogue"
        # Use negative lookahead equivalent - check for bold followed by non-colon then quote
        COLON_CHECK=""
        while IFS= read -r line_data; do
            line_num=$(echo "$line_data" | cut -d: -f1)
            line_content=$(echo "$line_data" | cut -d: -f2-)
            
            # Extract what comes after the bold name
            after_name=$(echo "$line_content" | sed 's/^__[^_]*__//')
            # Check if it starts with something other than a colon
            if [ -n "$after_name" ] && [ "${after_name:0:1}" != ":" ]; then
                # Check if it contains quotes (dialogue indicator)
                if echo "$after_name" | grep -q "\""; then
                    # Check if it's dialogue pattern (space followed by quote)
                    if echo "$after_name" | grep -qE "^[[:space:]]+\""; then
                        COLON_CHECK="${COLON_CHECK}${line_num}:${line_content}\n"
                    fi
                fi
            fi
        done < <(grep -n "^__[^_]*__" "$file")
        
        if [ -n "$COLON_CHECK" ]; then
            ((MISTAKE_COUNT++))
            echo -e "$COLON_CHECK" | while IFS= read -r line; do
                [ -n "$line" ] && add_error "❌ $file:$line - Missing colon after character name in dialogue"
            done
        fi
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo -e "$ERROR_MESSAGES"
    exit 1
else
    exit 0
fi