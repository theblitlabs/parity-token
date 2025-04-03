#!/bin/sh

echo "Running tests..."

# Run Forge tests
if ! forge test; then
    echo "Error: Tests failed"
    exit 1
fi

echo "✓ All tests passed"
exit 0 