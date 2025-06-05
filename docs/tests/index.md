# GitScrolls Test Suite Documentation

## Overview
This directory contains documentation for the narrative testing framework designed to validate the consistency and integrity of the GitScrolls project.

## Test Suites

### Core Validation
1. **[Link Graph Validator](./01-link-graph-validator.md)** - Ensures all document links are valid and properly connected
2. **[Character Consistency](./02-character-consistency.md)** - Tracks character evolution and naming consistency
3. **[Timeline Validator](./03-timeline-validator.md)** - Validates chronological consistency across the narrative
4. **[Scar System Tracker](./04-scar-system-tracker.md)** - Monitors the acquisition and evolution of wisdom scars
5. **[Lesson Consistency](./05-lesson-consistency.md)** - Ensures teachings remain consistent across scrolls

### Additional Test Suites (Planned)
6. **Metadata Linter** - Validates frontmatter format and consistency
7. **Quote Attribution Validator** - Ensures dialogue is properly attributed
8. **Technical Reference Validator** - Verifies accuracy of technical examples
9. **World-Building Consistency** - Tracks locations, institutions, and systems
10. **Narrative Arc Validator** - Ensures story structure and promises are fulfilled

## Running Tests

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- --testNamePattern="Link Graph"

# Run tests in Docker
docker-compose run tests

# Run tests with coverage
npm test -- --coverage
```

## Test Output Format

All tests output standardized JSON results:

```json
{
  "suite": "test-name",
  "passed": boolean,
  "timestamp": "ISO-8601",
  "summary": {
    "total": number,
    "passed": number,
    "failed": number
  },
  "errors": [
    {
      "type": "error-type",
      "severity": "error|warning",
      "file": "path/to/file.md",
      "line": number,
      "description": "Human-readable error description",
      "suggestion": "How to fix this error"
    }
  ]
}
```

## Contributing New Tests

See [development.md](./development.md) for guidelines on adding new test suites.