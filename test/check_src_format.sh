#!/bin/sh
#
# This script validates source links composition

# Get into the project root folder
project_root=$(dirname $0)
cd $project_root
cd ..

# Check source format
has_error=0

echo "Checking source format..."

while IFS=  read -r; do
    echo Error: $REPLY
    has_error=1
done < <(grep -Hn -R -E "src=[\"']file://" **/*.md)

exit $has_error
