#!/bin/bash

# Script to validate CHRONICLER formatting in GitScrolls
# Returns 0 if all checks pass, 1 if any issues found

ERRORS=0
ERROR_MESSAGES=""

# Function to add error message
add_error() {
    ERRORS=$((ERRORS + 1))
    ERROR_MESSAGES="${ERROR_MESSAGES}\n$1"
}

# Check all scroll files
for file in scrolls/*.md; do
    if [ -f "$file" ]; then
        echo "Checking $file..."
        
        # Check 1: CHRONICLER dialogue should use "___CHRONICLER:___" (bold and italic)
        # Look for incorrectly formatted CHRONICLER labels
        if grep -n "^[^_]*CHRONICLER:" "$file" | grep -v "___CHRONICLER:___" > /dev/null; then
            LINES=$(grep -n "^[^_]*CHRONICLER:" "$file" | grep -v "___CHRONICLER:___")
            add_error "❌ $file: CHRONICLER label should be '___CHRONICLER:___' (bold and italic):\n$LINES"
        fi
        
        # Check 2: CHRONICLER stage directions should be in _(parentheses)_
        # Any italicized text that's not a single word or inside dialogue should have parentheses
        awk '
        /### 🎭 Invocation|### 🎭 Closing/ { in_chronicler = 1; next }
        /^### / && !/🎭/ { in_chronicler = 0 }
        in_chronicler && /^_.*_$/ {
            # Skip if it has parentheses (correct format)
            if (/^_\(.*\)_$/) next
            # Skip if it is a single word emphasis
            if (/^_[^[:space:]]+_$/) next
            # Otherwise flag it
            print FILENAME ":" NR ": CHRONICLER action/stage direction needs parentheses: " $0
        }
        ' "$file" | while read -r line; do
            if [ -n "$line" ]; then
                add_error "❌ $line"
            fi
        done
        
        # Check 3: Multi-line CHRONICLER actions should have proper parentheses
        # Look for stage directions that span multiple lines
        awk '
        /### 🎭 Invocation|### 🎭 Closing/ { in_chronicler = 1; next }
        /^### / && !/### 🎭/ { in_chronicler = 0 }
        in_chronicler && /^_\(/ { 
            start_line = NR
            content = $0
            while (getline && !/\)_$/) {
                content = content " " $0
            }
            if (!/\)_$/) {
                print FILENAME ":" start_line ": Unclosed CHRONICLER stage direction"
            }
        }
        ' "$file" | while read -r line; do
            if [ -n "$line" ]; then
                add_error "❌ $line"
            fi
        done
        
        # Check 4: CHRONICLER dialogue after "CHRONICLER:" should not be italicized
        # unless it's for emphasis (which should be bold)
        awk '
        /^CHRONICLER:/ {
            getline
            if (/^_[^_].*[^_]_$/ && !/__(.*?)__/) {
                print FILENAME ":" NR ": CHRONICLER dialogue should not be italicized (use __bold__ for emphasis)"
            }
        }
        ' "$file" | while read -r line; do
            if [ -n "$line" ]; then
                add_error "❌ $line"
            fi
        done
    fi
done

# Report results
if [ $ERRORS -eq 0 ]; then
    echo "✅ All CHRONICLER formatting checks passed!"
    exit 0
else
    echo -e "\n❌ Found $ERRORS CHRONICLER formatting issues:"
    echo -e "$ERROR_MESSAGES"
    echo -e "\nCHRONICLER Style Guide:"
    echo "- Stage directions: _(Action in parentheses.)_"
    echo "- Dialogue label: ___CHRONICLER:___ (bold and italic)"
    echo "- Emphasis in dialogue: __bold__ (not plain italics)"
    exit 1
fi