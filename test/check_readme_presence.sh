#!/bin/sh
# This script validates the presence of project
# README files on every folder

# Get into the project root folder
project_root=$(dirname $0)
cd $project_root
cd ..

echo "Testing folder structure...";
has_error=0

# Get all folders
tmp_file="$(mktemp -p "$PWD")"
find "." \
  -type d \
  -not -path '*/.*' \
  -not -path '*/test*' \
  -not -path '*/assets*' \
  -not -path '*/scripts*' \
  -print > "${tmp_file}"

while IFS=  read -r 'folder'; do
  # Check if every folder has a README.md file
  if [ -f "$folder/.lava" ]; then
    echo "INFO: $folder/.lava file found, it's hot! skipping"
    continue
  fi

  if [ ! -f "$folder/README.md" ]; then
    echo "ERROR: $folder/README.md does not exist"
    has_error=1
  fi
done <"$tmp_file"

rm -f "$tmp_file"

exit $has_error
