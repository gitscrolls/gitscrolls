# Character Consistency Tracker

## Purpose
Ensures character names, evolution, and references remain consistent throughout the narrative.

## Test Cases

### 1. Character Evolution Tracking
- **What it tests**: Characters transform in the correct sequence
- **Implementation**: Track character name appearances by document order
- **Example failure**: "Tuxilles" appearing before "Tuxrates"

### 2. Character Introduction Validation
- **What it tests**: Characters are introduced before being referenced
- **Implementation**: Build first-appearance map, validate all references
- **Example failure**: "The Ancient Reviewer" mentioned in Scroll 3 but introduced in Scroll 8

### 3. Name Spelling Consistency
- **What it tests**: Character names are spelled consistently
- **Implementation**: Fuzzy matching to detect variations
- **Example failure**: "LinusTheElder" vs "Linus the Elder"

### 4. Character Attribute Consistency
- **What it tests**: Character descriptions remain consistent
- **Implementation**: Extract and compare character attributes
- **Example failure**: "Prophet Nia of the Honest Glass" later called "Nia the Honest Glass"

### 5. Character Arc Validation
- **What it tests**: Character development follows narrative logic
- **Implementation**: Validate state transitions (student → teacher)
- **Example failure**: Character regains lost abilities without explanation

## Implementation Details

```typescript
interface Character {
  names: string[];
  aliases: string[];
  firstAppearance: DocumentLocation;
  evolution: CharacterState[];
  attributes: Map<string, string>;
}

interface CharacterState {
  name: string;
  document: string;
  acquisitions: string[]; // scars, knowledge, etc.
  losses: string[]; // identity markers lost
}

class CharacterTracker {
  extractCharacters(): Map<string, Character>;
  validateEvolution(): ValidationResult[];
  detectInconsistencies(): Inconsistency[];
}
```

## Special Cases

### The Protagonist Evolution
```
Tuxicles (Scrolls I-IV) → 
Tuxrates (Scroll V start) → 
Tuxilles (Scroll V end - X)
```

### Scar Acquisition Timeline
1. Beak chip - Scroll V
2. Eye flickers - Scroll VI
3. Chest crack - Scroll VII
4. Flipper tingle - Scroll VII
5. Integration - Scroll VIII

## Expected Output

```json
{
  "characters": {
    "protagonist": {
      "evolution": ["Tuxicles", "Tuxrates", "Tuxilles"],
      "valid": true
    }
  },
  "errors": [
    {
      "type": "premature_reference",
      "character": "Tuxippides-v1",
      "file": "00-merge.lore",
      "line": 204,
      "issue": "Character referenced without introduction"
    }
  ]
}
```