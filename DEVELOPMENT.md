# GitScrolls Development Guide

## 🐳 Docker-First Development

This project runs **EVERYTHING** in Docker. You should never see a `node_modules` directory locally.

## Quick Start

```bash
# Run ALL tests (linting, validation, jest tests) - exactly like CI
npm test

# Run specific test suites
npm run test:syntax    # Markdown syntax tests
npm run test:style     # Style consistency tests

# Lint markdown files
npm run lint           # Check for issues
npm run lint:fix       # Auto-fix issues

# Get a shell inside the container
npm run shell
```

## Available Commands

All npm commands automatically run in Docker:

| Command | Description |
|---------|-------------|
| `npm test` | Run ALL validations (lint + GitScrolls style + all tests) |
| `npm run test:ci` | Run tests with CI flags and coverage |
| `npm run test:syntax` | Run markdown syntax validation |
| `npm run test:style` | Run style consistency validation |
| `npm run lint` | Check markdown files |
| `npm run lint:fix` | Auto-fix markdown issues |
| `npm run shell` | Open bash shell in container |

## Git Hooks

Pre-commit and pre-push hooks run all validations in Docker automatically.

## Internal Commands

Commands prefixed with `in_docker:` are for internal use only - they run inside the container:

- `in_docker:test`, `in_docker:lint`, etc.

## No Local Node

- ❌ Never run `npm install` locally
- ❌ Never run tests outside Docker
- ✅ Everything runs in containers
- ✅ Consistent environment for everyone
