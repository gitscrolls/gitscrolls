#!/bin/bash

# Quiet CHRONICLER validation script for GitScrolls
# Only outputs errors, no verbose progress

ERRORS=0
ERROR_MESSAGES=""

# Add color support
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to add error message
add_error() {
    ERRORS=$((ERRORS + 1))
    ERROR_MESSAGES="${ERROR_MESSAGES}\n$1"
}

# Check only git-tracked scroll files
for file in $(git ls-files 'scrolls/*.md'); do
    if [ -f "$file" ]; then
        # Check if file has CHRONICLER sections
        if ! grep -q "### 🎭" "$file"; then
            continue
        fi
        
        # Check 1: CHRONICLER dialogue should use "___CHRONICLER:___" (bold and italic)
        LABEL_CHECK=$(grep -n "^[^_]*CHRONICLER:" "$file" | grep -v "___CHRONICLER:___" || true)
        if [ -n "$LABEL_CHECK" ]; then
            while IFS= read -r line; do
                add_error "❌ $file:$line - CHRONICLER should be ___CHRONICLER:___ (bold and italic)"
            done <<< "$LABEL_CHECK"
        fi
        
        # Disabled: Stage direction checks - too many false positives
        # The scrolls use italics for many purposes beyond stage directions
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo -e "$ERROR_MESSAGES"
    exit 1
else
    exit 0
fi