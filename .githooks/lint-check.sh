#!/bin/sh

echo "Running linting checks..."

# Run solhint for Solidity files
if ! forge fmt --check; then
    echo "Error: Code formatting check failed."
    echo "Please run 'forge fmt' to format your code."
    exit 1
fi

# Run solhint
if command -v solhint >/dev/null 2>&1; then
    if ! solhint "src/**/*.sol"; then
        echo "Error: Solidity linting failed."
        exit 1
    fi
else
    echo "Warning: solhint is not installed. Skipping Solidity linting."
fi

echo "✓ Linting checks passed"
exit 0 