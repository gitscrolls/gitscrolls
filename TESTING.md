# GitScrolls Testing Suite

This repository validates both the syntax and style consistency of all GitScrolls to ensure they're properly formatted and maintain a consistent voice throughout the narrative.

## Initial Setup

To set up the development environment with git hooks:

```bash
npm run setup
```

This will:
1. Install npm dependencies
2. Install git hooks (pre-push validation)

You can also install just the hooks with:
```bash
npm run install-hooks
```

## What It Tests

### Syntax Validation (`npm run test:syntax`)
- **All 16 GitScrolls** in the `/scrolls` directory
- **README.md** in the root directory
- Checks for:
  - Unclosed code blocks (` ``` `)
  - Basic Markdown parsing errors

### Style Consistency (`npm run test:style`)
- **Frontmatter Format**: Ensures traditional YAML frontmatter with all required fields
- **Quote Formatting**: Main quotes should use bold (`__"quote"__`) not italics
- **Section Headers**: Should use "Scene" with Roman numerals (not "Act")
- **Character Dialogue**: Should use underline format (`__Name:__`)
- **Footer Attribution**: All scrolls must have the standard attribution block
- **Navigation Links**: Should use bold format (`**Next:**`)
- **Teaching Numbers**: Must match scroll numbers (e.g., "Fifth Teaching" for Scroll V)

## Running Tests

### With Docker (Recommended)

```bash
# Run tests
docker compose run --rm test

# Run tests as CI would
docker compose run --rm -e CI=true test npm run test:ci
```

### Without Docker

```bash
# Install dependencies
npm ci

# Run tests
npm test

# Run tests as CI would
npm run test:ci
```

## GitHub Actions

The tests run automatically on:
- Every push to main/master
- Every pull request

The workflow is defined in `.github/workflows/markdown-validation.yml`

## Test Output

When all tests pass:
```
PASS  src/__tests__/markdown-syntax.test.ts
  GitScrolls Markdown Syntax Validation
    ✓ Scroll: 01-Unbroken-Line.md should have valid Markdown syntax
    ✓ Scroll: 02-Annals-of-Forgotten-Messages.md should have valid Markdown syntax
    ... (14 more scrolls)
    ✓ README.md should have valid Markdown syntax
    ✓ should validate exactly 16 scrolls plus README
```

When errors are found, you'll see:
```
Markdown syntax errors in 02-Annals-of-Forgotten-Messages.md:
Line 311, Column 45: Unmatched underscore (_) for italic emphasis
```

---

*"Valid syntax flows like water through the scrolls."* - The ScrollKeeper