#!/bin/sh
set -e

# Get the directory of the current script
current_dir=$(dirname "$(readlink -f "$0")")
root_project="${current_dir}/../"

choice=${1:-}

if [ -z "$choice" ]; then
  echo "Choose an option:"
  echo "1. Convert to Obsidian"
  echo "2. Convert to Markdown"

  printf "Enter your choice (1 or 2): "
  read -r choice;
fi

case $choice in
    1)
        # fix markdown []() links by replacing - with %20
        echo "Converting Markdown links to Obsidian links..."
        find "$root_project" -type f -name "*.md" -exec sed -i -E ':a;s/(\[[^]]+|\][^(]+)(\]\([^#)]+)([^-)]+)-([^)]+)/\1\2\3%20\4/gI;ta;'  {} +

        # fix img src="" links by adding file path to project file://...
        echo "Converting Markdown local src to Obsidian absolute src..."
        root_path=$(echo "$root_project" | sed 's/[&/\]/\\&/g')
        find "$root_project" -type f -name "*.md" -exec sed -i -E "s#(src=[\"'])/#\1file://$root_path#g" {} +
        ;;
    2)
        # fix markdown []() links by replacing %20 with -
        echo "Converting Obsidian links to Markdown links..."
        find "$root_project" -type f -name "*.md" -exec sed -i -E ':a;s/(\[[^]]+|\][^(]+)(\]\([^#)]+)([^%)]+|%[^2)][^0)])%20([^)]+)/\1\2\3-\4/gI;ta;' {} +

        # fix img src="" links by removing file path to project file://...
        echo "Converting Obsidian absolute src to Markdown local src..."
        root_path=$(echo "$root_project" | sed 's/[^^]/[&]/g; s/\^/\\^/g')
        find "$root_project" -type f -name "*.md" -exec sed -i -E "s#(src=[\"'])file://$root_path#\1/#gI" {} +
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac
