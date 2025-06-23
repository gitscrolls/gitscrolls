#!/bin/bash

# Script to validate dialogue formatting in GitScrolls
# Ensures all dialogue follows: __Character__: "Speech"
# Returns 0 if all checks pass, 1 if any issues found

ERRORS=0
ERROR_MESSAGES=""

# Function to add error message
add_error() {
    ERRORS=$((ERRORS + 1))
    ERROR_MESSAGES="${ERROR_MESSAGES}\n$1"
}

# Known character names (add more as needed)
CHARACTERS="Tuxrates|Tuxicles|Linus|Prophet Nia|Fork-Bearer|Elena|The Trickster|TempleSentinel|Ghost Developer|Damned Developer|Force Push Demon|CI/CD Serpent|Eternal Rebaser|Rebase Demon"

# Check all scroll files
for file in scrolls/*.md; do
    if [ -f "$file" ]; then
        echo "Checking dialogue in $file..."
        
        # Check 1: Character names should be bold (__Character__)
        # Look for dialogue patterns that don't have proper bold formatting
        grep -n "^\(${CHARACTERS}\):" "$file" 2>/dev/null | while read -r line; do
            if ! echo "$line" | grep -q "^[0-9]*:__.*__:"; then
                add_error "❌ $file:$line - Character name should be bold: __Character__:"
            fi
        done
        
        # Check 2: Dialogue should be in quotes (with some exceptions)
        # Look for character dialogue that's missing quotes
        awk -v chars="$CHARACTERS" '
        BEGIN { 
            split(chars, char_array, "|")
            for (i in char_array) {
                char_pattern = char_pattern "|^__" char_array[i] "__:"
            }
            # Remove leading |
            char_pattern = substr(char_pattern, 2)
        }
        match($0, char_pattern) {
            # Get everything after the colon
            line_after_colon = substr($0, RSTART + RLENGTH)
            # Remove leading/trailing whitespace
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line_after_colon)
            
            # Skip if empty or just an action
            if (line_after_colon == "" || line_after_colon ~ /^_\(.*\)_[[:space:]]*$/) {
                next
            }
            
            # Skip if it starts with an action followed by quotes
            if (line_after_colon ~ /^_\(.*\)_[[:space:]]*"/) {
                next
            }
            
            # Check if dialogue is in quotes (allowing for actions before quotes)
            if (line_after_colon !~ /^".*"[[:space:]]*$/ && 
                line_after_colon !~ /^_\(.*\)_[[:space:]]*".*"[[:space:]]*$/) {
                # Some exceptions for short responses or code
                if (line_after_colon !~ /^(Yes|No|```|Three\.|One\.)$/) {
                    print FILENAME ":" NR ": Dialogue should be in quotes: " $0
                }
            }
        }
        ' "$file" | while read -r line; do
            if [ -n "$line" ]; then
                add_error "❌ $line"
            fi
        done
        
        # Check 3: CHRONICLER sections should NOT use character dialogue format
        # CHRONICLER uses a different format
        if grep -n "^__CHRONICLER__:" "$file" > /dev/null; then
            LINES=$(grep -n "^__CHRONICLER__:" "$file")
            add_error "❌ $file: CHRONICLER should not use character dialogue format:\n$LINES"
        fi
        
        # Check 4: Check for common formatting mistakes
        # Like space before colon, missing colon, etc.
        grep -n "^__.*__ :" "$file" 2>/dev/null | while read -r line; do
            add_error "❌ $file:$line - Remove space before colon"
        done
        
        grep -n "^__.*__[^:].*\"" "$file" 2>/dev/null | while read -r line; do
            # Skip URLs and other valid non-dialogue uses
            if ! echo "$line" | grep -q "http\|Freedom [0-9]"; then
                add_error "❌ $file:$line - Missing colon after character name"
            fi
        done
    fi
done

# Report results
if [ $ERRORS -eq 0 ]; then
    echo "✅ All dialogue formatting checks passed!"
    exit 0
else
    echo -e "\n❌ Found $ERRORS dialogue formatting issues:"
    echo -e "$ERROR_MESSAGES"
    echo -e "\nDialogue Style Guide:"
    echo "- Character dialogue: __Character__: \"Speech\""
    echo "- With action: __Character__: _(action)_ \"Speech\""
    echo "- CHRONICLER uses different format: CHRONICLER: (no bold, no quotes)"
    echo "- Short responses (Yes/No) may omit quotes"
    exit 1
fi