# GitScrolls Testing Framework

This project includes a narrative testing framework to ensure consistency across all GitScrolls documents.

## Quick Start

```bash
# Install dependencies
npm install

# Run tests
npm test

# Validate GitScrolls
npm run validate:gitscrolls

# Run in Docker
docker-compose run tests
```

## What Gets Tested

Currently implemented:
- **Link Validation**: All internal links between documents are checked
- **Orphan Detection**: Documents unreachable from README files are flagged
- **Title Consistency**: Link text is compared against target document titles

Planned validators:
- Character consistency tracking
- Timeline validation
- Scar system tracking
- Lesson consistency
- Technical reference validation

## Test Output

The validator provides detailed error reports:

```
link-graph-validator:
  Status: ❌ FAILED
  Errors: 1
  Warnings: 2
  
  - [error] scrolls/05-Wounding-of-Hubris.md:300 - Broken link: "The Siren's Song of Easy Chaos" points to non-existent file
  - [warning] README.md:45 - Link text "GitScroll I" may not match target document title "GitScroll I: The Unbroken Line"
```

## Development

See [docs/tests/development.md](docs/tests/development.md) for information on adding new validators.

## Docker Support

The framework includes Docker support for consistent testing environments:

```bash
# Build and run tests
docker-compose up --build

# Run specific validator
docker-compose run tests npm run validate:gitscrolls
```