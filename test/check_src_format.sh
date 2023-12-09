#!/bin/sh
# This script validates source links composition

# Get into the project root folder
project_root=$(dirname $0)
cd $project_root
cd ..

# Check source format
echo "Checking source format..."
has_error=0

tmp_file="$(mktemp -p "$PWD")"
grep -Hn \
  -R \
  -E "src=[\"']file://" \
  **/*.md > "${tmp_file}"

while IFS=  read -r 'REPLY'; do
    echo Error: $REPLY
    has_error=1
done < "$tmp_file"

rm -f "$tmp_file"

exit $has_error
