#!/bin/sh
#
# This script validates the presence of project
# README files on every folder

# Get into the project root folder
project_root=$(dirname $0)
cd $project_root
cd ..

echo "Testing folder structure...";

# Get all folders
folders=()
while IFS= read -r -d $'\0'; do
  folders+=("$REPLY")
done < <(find "." \
  -type d \
  -not -path '*/.*' \
  -not -path '*/test*' \
  -not -path '*/assets*' \
  -not -path '*/scripts*' \
  -print0\
)

echo "Found ${#folders[@]} folders. Testing README presence..."

# Check if every folder has a README.md file
has_error=0
for folder in "${folders[@]}"; do
  if [ ! -f "$folder/README.md" ]; then
    echo "ERROR: $folder/README.md does not exist"
    has_error=1
  fi
done

exit $has_error
