#!/bin/bash
set -e  # Exit on error

name_prefix="gs-sandbox"
environment="${environment}"
execution_name="demo"

echo "This is ${name_prefix}-${environment}-${execution_name} and it is ready to start..."

# Run the main application command
exec "$@"