#!/bin/sh
#
# This script validates the correct readme file names on 
# the project following a non-space name convention.

# Get into the project root folder
cd "$(dirname "$0")"
cd ..

echo "Testing files structure...";

# Get all folders
files=()
while IFS= read -r -d $'\0'; do
  files+=("$REPLY")
done < <(find "." \
  -type f \
  -not -path '*/.*' \
  -not -path '*/test*' \
  -not -path '*/assets*' \
  -not -path '*/scripts*' \
  -print0\
)

echo "Found ${#files[@]} files. Testing naming convention..."

# Check if every file has the proper name convention
has_error=0
for file in ${files[@]}; do
  # allowed characters are [a-zA-Z0-9_-]
  name_only=$(basename "$file")
  name_only=${name_only%.*}

  if [[ $name_only =~ [^a-zA-Z0-9_-] ]]; then
    echo "File '$file' is not following the file convention. [a-zA-Z0-9_-]";
    has_error=1
  fi
done

exit $has_error
