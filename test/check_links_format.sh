#!/bin/sh
# This script validates links composition

# Get into the project root folder
project_root="$(dirname $0)"
cd "$project_root"
cd ..

# Check links format
has_error=0

echo "Validating links format..."

tmp_file="$(mktemp -p "$PWD")"
grep -Hn \
  -R \
  -E '\[[^]]+\]\([^)#]+#[^)]+%20[^)]+\)' \
  **/*.md *.md 

while IFS=  read -r REPLY; do
    has_error=1
    echo "Error: $REPLY"
done < "$tmp_file"

rm -f "$tmp_file"
exit $has_error
