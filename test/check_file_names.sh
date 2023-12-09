#!/bin/sh
#
# This script validates the correct readme file names on 
# the project following a non-space name convention.

# Get into the project root folder
cd "$(dirname "$0")"
cd ..

echo "Testing files structure...";
has_error=0

# Get all folders
tmp_file="$(mktemp -p "$PWD")"
find "." \
  -type f \
  -not -path '*/.*' \
  -not -path '*/test*' \
  -not -path '*/assets*' \
  -not -path '*/scripts*' \
  -print > "${tmp_file}"

while IFS= read -r 'file'; do
  # Check if every file has the proper name convention
  # allowed characters are [a-zA-Z0-9_-]
  name_only=$(basename "$file")
  name_only=${name_only%.*}

  if echo "$name_only" | grep -q '[^a-zA-Z0-9_-]'; then
    echo "File '$file' is not following the file convention. [a-zA-Z0-9_-]";
    has_error=1
  fi
done < "$tmp_file"

rm -f "$tmp_file"

exit $has_error
