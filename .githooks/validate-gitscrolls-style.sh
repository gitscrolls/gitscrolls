#!/bin/bash

# Master validation script for GitScrolls style
# Runs all style checks and reports results

# Add color support
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Quiet mode - capture output
CHRONICLER_OUTPUT=$(bash .githooks/validate-chronicler-style-quiet.sh 2>&1)
CHRONICLER_EXIT=$?

DIALOGUE_OUTPUT=$(bash .githooks/validate-dialogue-format-quiet.sh 2>&1)
DIALOGUE_EXIT=$?

TOTAL_ERRORS=0
if [ $CHRONICLER_EXIT -ne 0 ]; then
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi
if [ $DIALOGUE_EXIT -ne 0 ]; then
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi

# Generate summary report
echo -e "${BLUE}# GITSCROLLS VALIDATION SUMMARY${NC}"
echo ""

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All style checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found style issues${NC}"
    echo ""
    
    # Parse and summarize CHRONICLER issues
    if [ $CHRONICLER_EXIT -ne 0 ]; then
        echo -e "${YELLOW}## CHRONICLER Issues${NC}"
        # Extract scroll-specific errors from output
        echo "$CHRONICLER_OUTPUT" | grep "^❌" | while IFS=: read -r file line rest; do
            scroll=$(basename "$file")
            if [ "$current_scroll" != "$scroll" ]; then
                echo ""
                echo -e "${BLUE}### $scroll${NC}"
                current_scroll="$scroll"
            fi
            echo "- Line $line: $rest"
        done
    fi
    
    # Parse and summarize dialogue issues
    if [ $DIALOGUE_EXIT -ne 0 ]; then
        echo ""
        echo -e "${YELLOW}## Dialogue Issues${NC}"
        # Extract scroll-specific errors from output
        echo "$DIALOGUE_OUTPUT" | grep "^❌" | while IFS=: read -r file line rest; do
            scroll=$(basename "$file")
            if [ "$current_scroll" != "$scroll" ]; then
                echo ""
                echo -e "${BLUE}### $scroll${NC}"
                current_scroll="$scroll"
            fi
            echo "- Line $line: $rest"
        done
    fi
    
    echo ""
    echo -e "${YELLOW}## Style Guide${NC}"
    echo "- CHRONICLER stage directions: _(Action in parentheses.)_"
    echo "- CHRONICLER dialogue: ___CHRONICLER:___ (bold and italic)"
    echo "- Character dialogue: __Character__: \"Speech\""
    echo "- Emphasis in dialogue: __bold__ not _italics_"
    
    exit 1
fi