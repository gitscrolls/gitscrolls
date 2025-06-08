# Lesson Consistency Checker

## Purpose
Validates that lessons, principles, and teachings remain consistent across all scrolls.

## Test Cases

### 1. Lesson Numbering Validation
- **What it tests**: Each scroll contains the expected number of lessons
- **Implementation**: Count lessons per scroll, verify against scroll number
- **Example failure**: Scroll V contains 6 principles instead of 7

### 2. Lesson Reference Accuracy
- **What it tests**: Lessons referenced in other scrolls match original
- **Implementation**: Build lesson database, validate all references
- **Example failure**: "Thou Shalt Not Rebase History" misquoted as "Never Rebase History"

### 3. Teaching Attribution
- **What it tests**: Lessons are attributed to correct teachers
- **Implementation**: Map lessons to their teachers
- **Example failure**: Fork-Bearer's lesson attributed to Linus

### 4. Lesson Application Tracking
- **What it tests**: Lessons are applied/violated as narrative describes
- **Implementation**: Track lesson violations and applications
- **Example failure**: Character violates lesson without consequence

### 5. Core Principle Consistency
- **What it tests**: Fundamental principles remain unchanged
- **Implementation**: Validate core teachings across documents
- **Example failure**: "Tests are love" becomes "Tests are optional"

## Implementation Details

```typescript
interface Lesson {
  id: string;
  scroll: string;
  teacher: string;
  title: string;
  content: string;
  coreMessage: string;
  applications: LessonApplication[];
}

interface LessonApplication {
  document: string;
  context: string;
  type: 'violation' | 'application' | 'reference';
}

class LessonTracker {
  extractLessons(): Map<string, Lesson>;
  validateReferences(): ValidationResult[];
  trackApplications(): LessonApplication[];
  verifyConsistency(): ConsistencyReport;
}
```

## Core Lessons Registry

### By Scroll
1. **Scroll I**: "Thou Shalt Not Rewrite History"
2. **Scroll II**: "Write Meaningful Commit Messages"
3. **Scroll III**: "Tests Are the Honest Glass"
4. **Scroll IV**: "Forks Are Not Betrayals"
5. **Scroll V**: Seven Principles of Compassionate Refactoring
6. **Scroll VI**: "Every Bug Is a Feature Request"
7. **Scroll VII**: "Sacred Timing"
8. **Scroll VIII**: "All Code Is Temporary, All Blame Is Eternal"
9. **Scroll IX**: "Be the Mentor You Needed When You Began"
10. **Scroll X**: "Wisdom Isn't a Destination"

## Expected Output

```json
{
  "lessons": {
    "total": 17,
    "by_scroll": {
      "I": 1, "II": 1, "III": 1, "IV": 1, "V": 7,
      "VI": 1, "VII": 1, "VIII": 1, "IX": 1, "X": 1
    }
  },
  "consistency": {
    "core_principles": "valid",
    "references": "valid",
    "applications": "valid"
  },
  "errors": []
}
```