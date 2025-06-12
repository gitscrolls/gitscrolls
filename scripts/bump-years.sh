#!/bin/bash

# GitScrolls Year Bumper Script
# Updates all year references to keep the story feeling current
# Usage: ./bump-years.sh [target_year]
# If no target year provided, uses current year

# Get target year (default to current year)
if [ -z "$1" ]; then
    TARGET_YEAR=$(date +%Y)
else
    TARGET_YEAR=$1
fi

# Calculate the year offsets
# The story has these key years:
# - Main catastrophe: December 2024
# - Exile/recovery: 2025 (various months)
# - Future mysterious file: 2027

CATASTROPHE_YEAR=$((TARGET_YEAR - 1))  # Previous December
RECOVERY_YEAR=$TARGET_YEAR             # Current year
FUTURE_YEAR=$((TARGET_YEAR + 2))       # Mysterious future file

echo "Updating GitScrolls to feel current for year $TARGET_YEAR..."
echo "  Catastrophe year: $CATASTROPHE_YEAR"
echo "  Recovery year: $RECOVERY_YEAR"
echo "  Future file year: $FUTURE_YEAR"
echo ""

# Create backup
echo "Creating backup..."
cp -r scrolls scrolls.backup.$(date +%Y%m%d_%H%M%S)

# Update files
echo "Updating year references..."

# Update all scrolls
for file in scrolls/*.md; do
    if [ -f "$file" ]; then
        # Create temp file
        temp_file="${file}.tmp"
        
        # Replace years in narrative content (not in metadata)
        # This uses more specific patterns to avoid changing metadata
        sed -E \
            -e "s/(December|Dec) [0-9]{1,2}[a-z]{0,2}, 2024/\1 \2, $CATASTROPHE_YEAR/g" \
            -e "s/(December|Dec) 2024/\1 $CATASTROPHE_YEAR/g" \
            -e "s/2024-12-21/$CATASTROPHE_YEAR-12-21/g" \
            -e "s/2024_12_21/${CATASTROPHE_YEAR}_12_21/g" \
            -e "s/(January|Jan|February|Feb|March|Mar|April|Apr|May) 2025/\1 $RECOVERY_YEAR/g" \
            -e "s/(January|Jan|February|Feb|March|Mar|April|Apr|May) [0-9]{1,2}[a-z]{0,2}, 2025/\1 \2, $RECOVERY_YEAR/g" \
            -e "s/([^0-9])2025([^0-9])/\1$RECOVERY_YEAR\2/g" \
            -e "s/ 2027 / $FUTURE_YEAR /g" \
            -e "s/2027\+/$FUTURE_YEAR+/g" \
            -e "s/RFC-2025-/RFC-$RECOVERY_YEAR-/g" \
            "$file" > "$temp_file"
        
        # Only update if changes were made
        if ! cmp -s "$file" "$temp_file"; then
            mv "$temp_file" "$file"
            echo "  Updated: $file"
        else
            rm "$temp_file"
        fi
    fi
done

echo ""
echo "Year bump complete!"
echo ""
echo "Note: This script updates narrative years but preserves metadata dates."
echo "Review the changes with: git diff"
echo "If something went wrong, restore from: scrolls.backup.*"