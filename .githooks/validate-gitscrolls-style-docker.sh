#!/bin/bash

# Docker-friendly validation script for GitScrolls style
# Removes color codes for better Docker compatibility

echo "🔍 Running GitScrolls style validation..."
echo "========================================"
echo ""

TOTAL_ERRORS=0

# Run CHRONICLER style validation
echo ""
echo "📜 Checking CHRONICLER formatting..."
echo "----------------------------------"
if bash .githooks/validate-chronicler-style.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g'; then
    echo "✅ CHRONICLER checks passed"
else
    echo "❌ CHRONICLER checks failed"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi

# Run dialogue format validation
echo ""
echo "💬 Checking dialogue formatting..."
echo "----------------------------------"
if bash .githooks/validate-dialogue-format.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g'; then
    echo "✅ Dialogue checks passed"
else
    echo "❌ Dialogue checks failed"
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
fi

echo ""
echo "========================================"

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo "✅ All style checks passed! Your GitScrolls are properly formatted."
    exit 0
else
    echo "❌ Found style issues in $TOTAL_ERRORS check(s). Please fix the issues above."
    echo ""
    echo "📚 Style Guide Summary:"
    echo "- CHRONICLER stage directions: _(Action in parentheses.)_"
    echo "- CHRONICLER dialogue: ___CHRONICLER:___ (bold and italic)"
    echo "- Character dialogue: __Character__: \"Speech\""
    echo "- Emphasis in dialogue: __bold__ not _italics_"
    exit 1
fi