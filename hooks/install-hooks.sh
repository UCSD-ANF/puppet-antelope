#!/bin/bash
#
# Install pre-commit hooks for puppet-antelope development
#

set -e

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: This script must be run from the root of the git repository"
    exit 1
fi

# Check if hooks directory exists
if [ ! -d "hooks" ]; then
    echo "Error: hooks directory not found"
    exit 1
fi

echo "Installing pre-commit hooks..."

# Install pre-commit hook
if [ -f "hooks/pre-commit" ]; then
    cp hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✓ Pre-commit hook installed"
else
    echo "Error: hooks/pre-commit not found"
    exit 1
fi

echo "✓ All hooks installed successfully!"
echo ""
echo "The pre-commit hook will now run 'pdk validate' before each commit."
echo "To bypass the hook (not recommended), use: git commit --no-verify"