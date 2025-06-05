# Link Graph Validator

## Purpose
Validates all hyperlinks between documents, ensuring navigation integrity and preventing broken references.

## Test Cases

### 1. Link Existence Validation
- **What it tests**: Every link target exists as a file
- **Implementation**: Parse markdown links, resolve relative paths, check file existence
- **Example failure**: `[Next scroll](./11-nonexistent.md)` when file doesn't exist

### 2. Link Title Accuracy
- **What it tests**: Link text matches the target document's actual title
- **Implementation**: Extract link text, parse target document title, compare
- **Example failure**: `[The Siren's Song](./06-Songs-of-Chaos-Sirens.md)` when actual title is "Songs of the Chaos Sirens"

### 3. Bidirectional Link Validation
- **What it tests**: Navigation links form proper sequences
- **Implementation**: Verify each document links to next/previous correctly
- **Example failure**: Scroll 5 links to Scroll 7, skipping Scroll 6

### 4. Orphan Detection
- **What it tests**: All documents are reachable from the main entry point
- **Implementation**: Build graph from README.md, find unreachable nodes
- **Example failure**: A scroll exists but no other document links to it

### 5. Circular Reference Detection
- **What it tests**: No infinite loops in navigation
- **Implementation**: Detect cycles in the link graph
- **Example failure**: A → B → C → A

## Implementation Details

```typescript
interface LinkNode {
  filepath: string;
  title: string;
  outgoingLinks: Link[];
  incomingLinks: Link[];
}

interface Link {
  text: string;
  target: string;
  line: number;
}

class LinkGraphValidator {
  buildGraph(): Map<string, LinkNode>;
  validateLinks(): ValidationResult[];
  detectOrphans(): string[];
  detectCycles(): string[][];
}
```

## Expected Output

```json
{
  "passed": false,
  "errors": [
    {
      "type": "broken_link",
      "file": "scrolls/05-Wounding-of-Hubris.md",
      "line": 300,
      "link_text": "The Siren's Song of Easy Chaos",
      "target": "./06-Songs-of-Chaos-Sirens.md",
      "expected_title": "Songs of the Chaos Sirens"
    }
  ]
}
```