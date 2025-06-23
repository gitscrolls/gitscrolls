#!/bin/bash

# Master validation script for GitScrolls style
# Runs all style checks and reports results

echo "🔍 Running GitScrolls style validation..."
echo "========================================"

TOTAL_ERRORS=0

# Run CHRONICLER style validation
echo -e "\n📜 Checking CHRONICLER formatting..."
if bash .githooks/validate-chronicler-style.sh; then
    echo "✅ CHRONICLER checks passed"
else
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi

# Run dialogue format validation
echo -e "\n💬 Checking dialogue formatting..."
if bash .githooks/validate-dialogue-format.sh; then
    echo "✅ Dialogue checks passed"
else
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi

# Additional style checks can be added here
# For example:
# - Check for consistent emphasis formatting
# - Check for proper code block formatting
# - Check for consistent scene numbering

echo -e "\n========================================"

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo "✅ All style checks passed! Your GitScrolls are properly formatted."
    exit 0
else
    echo "❌ Found style issues in $TOTAL_ERRORS check(s). Please fix the issues above."
    echo -e "\n📚 Style Guide Summary:"
    echo "- CHRONICLER stage directions: _(Action in parentheses.)_"
    echo "- CHRONICLER dialogue: ___CHRONICLER:___ (bold and italic)"
    echo "- Character dialogue: __Character__: \"Speech\""
    echo "- Emphasis in dialogue: __bold__ not _italics_"
    exit 1
fi