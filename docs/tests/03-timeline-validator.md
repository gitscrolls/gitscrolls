# Timeline Validator

## Purpose
Ensures chronological consistency across all temporal references in the narrative.

## Test Cases

### 1. Date Parsing and Extraction
- **What it tests**: All date formats are recognized and parsed correctly
- **Implementation**: Regex patterns for various date formats
- **Example formats**: "December 2024", "Mon Jan 8 14:23:17 2025", "18 months in the future"

### 2. Chronological Order Validation
- **What it tests**: Events occur in logical sequence
- **Implementation**: Build timeline, check for violations
- **Example failure**: Event in March references "last month" event from January

### 3. Relative Time Validation
- **What it tests**: Relative time references are mathematically consistent
- **Implementation**: Convert relative references to absolute dates
- **Example failure**: "18 months from April 2025" ≠ "June 2027"

### 4. Narrative Time Progression
- **What it tests**: Story time moves forward logically between scrolls
- **Implementation**: Verify each scroll's timeframe follows the previous
- **Example failure**: Scroll VII (February) followed by Scroll VIII (January)

### 5. Future Reference Consistency
- **What it tests**: Future events maintain consistent distance
- **Implementation**: Track prophecies and validate when reached
- **Example failure**: "Two years hence" changes to "Three years hence" without time passing

## Implementation Details

```typescript
interface TemporalEvent {
  description: string;
  timestamp: Date | RelativeTime;
  document: string;
  line: number;
  type: 'absolute' | 'relative' | 'narrative';
}

interface RelativeTime {
  anchor: Date;
  offset: Duration;
  reference: string; // "18 months in the future"
}

class TimelineValidator {
  extractEvents(): TemporalEvent[];
  buildTimeline(): Timeline;
  validateChronology(): ValidationResult[];
  resolveRelativeTime(event: TemporalEvent): Date;
}
```

## Known Timeline

### Main Narrative Arc
- **Scrolls I-IV**: Learning phase (pre-December 2024)
- **Scroll V**: The Incident (December 2024)
- **Scroll VI**: Recovery begins (January 2025)
- **Scroll VII**: The Trial (February 2025)
- **Scroll VIII**: Understanding (March 2025)
- **Scroll IX**: Teaching (April 2025)
- **Scroll X**: Return (May 2025)

### Special Events
- **The Trickster's Commit**: June 15, 2027
- **00-merge.lore**: Evolves across time

## Expected Output

```json
{
  "timeline": {
    "valid": false,
    "events": 47,
    "errors": [
      {
        "type": "inconsistent_relative_time",
        "event1": {
          "file": "scrolls/06-Songs-of-Chaos-Sirens.md",
          "description": "Commit from June 15, 2027"
        },
        "event2": {
          "file": "scrolls/09-Commandments-of-Wise.md",
          "description": "Still 18 months in future from April 2025"
        },
        "expected": "October/November 2026",
        "actual": "June 2027"
      }
    ]
  }
}
```