# Test Development Guide

## Adding New Test Suites

### 1. Identify Test Need
Before creating a new test, consider:
- What consistency issue does this test catch?
- Could an existing test be extended instead?
- Is this a one-time check or ongoing validation need?

### 2. Design Test Cases
Each test suite should include:
- Clear purpose statement
- 3-7 specific test cases
- Implementation approach
- Expected output format

### 3. Implementation Pattern

```typescript
import { BaseValidator, ValidationResult } from '../core/base-validator';

export class YourValidator extends BaseValidator {
  name = 'your-validator';
  
  async validate(): Promise<ValidationResult> {
    const errors = [];
    
    // Your validation logic here
    
    return {
      suite: this.name,
      passed: errors.length === 0,
      timestamp: new Date().toISOString(),
      summary: {
        total: checksPerformed,
        passed: checksPerformed - errors.length,
        failed: errors.length
      },
      errors
    };
  }
}
```

### 4. Documentation Requirements
Create a markdown file in `docs/tests/` with:
- Purpose section
- Test cases with examples
- Implementation details
- Expected output

### 5. Test Your Test
- Unit test the validator logic
- Run against known-good state
- Introduce deliberate errors to verify detection
- Check performance on full document set

## Best Practices

### Performance
- Parse documents once, analyze multiple times
- Use streaming for large files
- Cache parsed results between related tests

### Error Reporting
- Include file path and line number
- Provide actionable fix suggestions
- Group related errors
- Use consistent severity levels

### Maintainability
- Keep validators focused on single concern
- Reuse parsing logic through shared utilities
- Document regex patterns and parsing assumptions
- Version test output for compatibility

## Common Utilities

### Markdown Parser
```typescript
import { parseMarkdown } from '../utils/markdown-parser';
```

### Link Extractor
```typescript
import { extractLinks } from '../utils/link-extractor';
```

### Frontmatter Parser
```typescript
import { parseFrontmatter } from '../utils/frontmatter-parser';
```

### Graph Builder
```typescript
import { buildGraph } from '../utils/graph-builder';
```

## Testing Philosophy

Remember: these tests serve the narrative, not the other way around. If a test becomes too restrictive and prevents legitimate creative evolution, it should be adjusted. The goal is to catch unintentional inconsistencies, not to freeze the story in amber.