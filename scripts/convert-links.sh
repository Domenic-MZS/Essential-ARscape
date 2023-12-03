#!/bin/sh

# Get the directory of the current script
current_dir=$(dirname "$(readlink -f "$0")")
root_project="${current_dir}/../"


echo "Choose an option:"
echo "1. Convert to Obsidian"
echo "2. Convert to Markdown"

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "Converting Markdown links to Obsidian links..."
        # fix markdown []() links
        find "$root_project" -type f -name "*.md" -exec sed -i -E ':a; s/([^!]\[.+\])\((.+)-(.+)\)/\1(\2%20\3)/g; ta' {} +

        echo "Converting Markdown local src to Obsidian absolute src..."
        # fix img src="" links
        escaped_root_project=$(echo "$root_project" | sed 's/\//\\\//g')
        find "$root_project" -type f -name "*.md" -exec sed -i -E "s#(src=[\"'])/#\1file://$escaped_root_project#g" {} +
        ;;
    2)
        echo "Converting Obsidian links to Markdown links..."
        find "$root_project" -type f -name "*.md" -exec  sed -i -E ':a; s/([^!]\[.+\])\((.+)%20(.+)\)/\1(\2-\3)/g; ta' {} +

        echo "Converting Obsidian absolute src to Markdown local src..."
        escaped_root_folder=$(echo "$root_project" | sed 's/\//\\\//g')
        find "$root_project" -type f -name "*.md" -exec sed -i -E "s#(src=[\"'])file:.+$escaped_root_folder#\1/#g" {} +
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac
