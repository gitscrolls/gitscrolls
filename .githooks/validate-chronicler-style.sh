#!/bin/bash

# Verbose CHRONICLER validation script for GitScrolls
# Shows detailed progress and what's being checked

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

# Check all scroll files
for file in scrolls/*.md; do
    if [ -f "$file" ]; then
        echo -e "\n${CYAN}📜 Checking $file...${NC}"
        
        # Check if file has CHRONICLER sections
        if ! grep -q "### 🎭" "$file"; then
            echo -e "  ${YELLOW}⏭️  No CHRONICLER sections found, skipping${NC}"
            continue
        fi
        
        echo -e "  ${BLUE}🔍 Running CHRONICLER validations:${NC}"
        
        # Check 1: CHRONICLER dialogue should use "___CHRONICLER:___" (bold and italic)
        echo -n "    • Checking CHRONICLER label format... "
        LABEL_CHECK=$(grep -n "^[^_]*CHRONICLER:" "$file" | grep -v "___CHRONICLER:___" || true)
        if [ -n "$LABEL_CHECK" ]; then
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ Labels should be ___CHRONICLER:___ (bold+italic)${NC}"
            add_error "❌ $file: CHRONICLER label should be '___CHRONICLER:___' (bold and italic):\n$LABEL_CHECK"
        else
            echo -e "${GREEN}✓${NC}"
        fi
        
        # Check 2: CHRONICLER stage directions should be in _(parentheses)_
        echo -n "    • Checking stage direction parentheses... "
        PAREN_CHECK=$(awk '
        /### 🎭 Invocation|### 🎭 Closing/ { in_chronicler = 1; next }
        /^### / && !/🎭/ { in_chronicler = 0 }
        in_chronicler && /^_.*_$/ {
            # Skip if it has parentheses (correct format)
            if (/^_\(.*\)_$/) next
            # Skip if it is a single word emphasis
            if (/^_[^[:space:]]+_$/) next
            # Otherwise flag it
            print NR ": " $0
        }
        ' "$file")
        
        if [ -n "$PAREN_CHECK" ]; then
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ Stage directions need parentheses${NC}"
            while IFS= read -r line; do
                add_error "❌ $file:$line - CHRONICLER action/stage direction needs parentheses"
            done <<< "$PAREN_CHECK"
        else
            echo -e "${GREEN}✓${NC}"
        fi
        
        # Check 3: Multi-line CHRONICLER actions should have proper parentheses
        echo -n "    • Checking multi-line stage directions... "
        MULTILINE_CHECK=$(awk '
        /### 🎭 Invocation|### 🎭 Closing/ { in_chronicler = 1; next }
        /^### / && !/🎭/ { in_chronicler = 0 }
        in_chronicler && /^_\(/ { 
            start_line = NR
            content = $0
            while (getline && !/\)_$/) {
                content = content " " $0
            }
            if (!/\)_$/) {
                print start_line ": Unclosed stage direction"
            }
        }
        ' "$file")
        
        if [ -n "$MULTILINE_CHECK" ]; then
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ Unclosed multi-line actions${NC}"
            while IFS= read -r line; do
                add_error "❌ $file:$line"
            done <<< "$MULTILINE_CHECK"
        else
            echo -e "${GREEN}✓${NC}"
        fi
        
        # Check 4: CHRONICLER dialogue after "CHRONICLER:" should not be italicized
        echo -n "    • Checking dialogue formatting... "
        DIALOGUE_CHECK=$(awk '
        /^CHRONICLER:|^___CHRONICLER:___/ {
            getline
            if (/^_[^_].*[^_]_$/ && !/__(.*?)__/) {
                print NR ": " $0
            }
        }
        ' "$file")
        
        if [ -n "$DIALOGUE_CHECK" ]; then
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ Dialogue shouldn't be italicized${NC}"
            while IFS= read -r line; do
                add_error "❌ $file:$line - CHRONICLER dialogue should not be italicized (use __bold__ for emphasis)"
            done <<< "$DIALOGUE_CHECK"
        else
            echo -e "${GREEN}✓${NC}"
        fi
    fi
done

# Report results
echo -e "\n${BLUE}========================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All CHRONICLER formatting checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS CHRONICLER formatting issues:${NC}"
    echo -e "$ERROR_MESSAGES"
    echo -e "\n${YELLOW}CHRONICLER Style Guide:${NC}"
    echo "- Stage directions: _(Action in parentheses.)_"
    echo "- Dialogue label: ___CHRONICLER:___ (bold and italic)"
    echo "- Emphasis in dialogue: __bold__ (not plain italics)"
    exit 1
fi