#!/bin/sh
#
# This script validates links composition

# Get into the project root folder
project_root=$(dirname $0)
cd $project_root
cd ..

# Check links format
has_error=0

echo "Validating links format..."

while IFS= read -r; do
    has_error=1
    echo Error: $REPLY
done < <(grep -Hn -R -E '(\[[^\)]+\]\([^\)]+#[^\)]+)%20([^\)]+)' **/*.md)

exit $has_error
