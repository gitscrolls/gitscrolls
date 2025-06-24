#!/bin/bash

# Verbose dialogue validation script for GitScrolls
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

# Known character names (add more as needed)
CHARACTERS="Tuxrates|Tuxicles|Linus|Prophet Nia|Fork-Bearer|Elena|The Trickster|TempleSentinel|Ghost Developer|Damned Developer|Force Push Demon|CI/CD Serpent|Eternal Rebaser|Rebase Demon"

echo -e "${BLUE}Starting dialogue format validation...${NC}"

# Check only git-tracked scroll files
for file in $(git ls-files 'scrolls/*.md'); do
    if [ -f "$file" ]; then
        echo -e "\n${CYAN}💬 Checking dialogue in $file...${NC}"
        echo -e "  ${BLUE}🔍 Running dialogue validations:${NC}"
        
        # Check 1: Character names should be bold (__Character__)
        echo -n "    • Checking character name formatting... "
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
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ Character names should be __Name__:${NC}"
            printf "$NAME_CHECK" | while IFS= read -r line; do
                [ -n "$line" ] && add_error "❌ $file:$line - Character name should be bold: __Character__:"
            done
        else
            echo -e "${GREEN}✓${NC}"
        fi
        
        # Check 2: CHRONICLER sections should NOT use character dialogue format
        echo -n "    • Checking CHRONICLER format... "
        CHRONICLER_CHECK=$(grep -n "^__CHRONICLER__:" "$file" 2>/dev/null || true)
        if [ -n "$CHRONICLER_CHECK" ]; then
            echo -e "${RED}❌ Found issues${NC}"
            echo -e "      ${YELLOW}→ CHRONICLER should use ___CHRONICLER:___${NC}"
            add_error "❌ $file: CHRONICLER should not use character dialogue format:\n$CHRONICLER_CHECK"
        else
            echo -e "${GREEN}✓${NC}"
        fi
        
        # Check 3: Check for common formatting mistakes
        echo -n "    • Checking for common mistakes... "
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
            printf "$COLON_CHECK" | while IFS= read -r line; do
                [ -n "$line" ] && add_error "❌ $file:$line - Missing colon after character name in dialogue"
            done
        fi
        
        # Disabled: Check for dialogue without character attribution
        # Some scrolls intentionally use unattributed dialogue for stylistic effect
        # NO_NAME_CHECK=$(grep -n "^[[:space:]]*\"" "$file" 2>/dev/null | grep -v "^[0-9]*:[[:space:]]*\"\"\"" || true)
        
        if [ $MISTAKE_COUNT -eq 0 ]; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}❌ Found $MISTAKE_COUNT types of mistakes${NC}"
        fi
        
        # Show character count
        CHAR_COUNT=$(grep -c "^__.*__:" "$file" 2>/dev/null || echo 0)
        echo -e "    ${BLUE}ℹ️  Found $CHAR_COUNT character dialogue lines${NC}"
    fi
done

# Report results
echo -e "\n${BLUE}========================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All dialogue formatting checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS dialogue formatting issues:${NC}"
    echo -e "$ERROR_MESSAGES"
    echo -e "\n${YELLOW}Dialogue Style Guide:${NC}"
    echo "- Character dialogue: __Character__: \"Speech\""
    echo "- With action: __Character__: _(action)_ \"Speech\""
    echo "- CHRONICLER uses different format: ___CHRONICLER:___ (bold+italic)"
    echo "- Short responses (Yes/No) may omit quotes"
    exit 1
fi