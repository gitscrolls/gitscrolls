#!/bin/bash

echo "📚 Installing GitScrolls git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy pre-commit hook
cp scripts/pre-commit.hook .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Copy pre-push hook
cp scripts/pre-push.hook .git/hooks/pre-push
chmod +x .git/hooks/pre-push

echo "✅ Git hooks installed successfully!"
echo "🔧 The pre-commit hook will auto-fix markdown issues."
echo "🔍 The pre-push hook will run tests before allowing pushes."