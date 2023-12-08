#!/bin/sh
set -e

# Replace all links to a file with a new name
# $1: file name to replace
# $2: new file name
function replace_links() {
  escaped_file_name=$(echo "$1" | sed 's#[^^]#[&]#g; s#\^#\\^#g')
  escaped_heading=$(echo "$2" | sed 's#[\&]#\\&#g')

  find "$root_project" \
    -type f \
    -name "*.md" \
    -not -path '*/\.*/*' \
    -print0 \
    | xargs -0 sed -i "s/${1// /%20}/${2// /%20}/g"
}

# Convert all markdown files to Obsidian format 
# using the first # heading as the file name for graphs
# (replacing spaces instead of dashes or underscores)
function obsidianize() {
  for file in "${@:1}"; do
    # Get the file original name
    file_name=$(basename -- "$file")
    heading= # new heading of the file

    echo "[?] Converting $file_name..."

    # Replace README.md with first # heading in file; 
    if [[ $file_name == "README.md" ]]; then
      heading=$(sed -En 's/(^|[[:space:]]+)#\s//p' "$file")

      # we use a prefix .h to indicate that this 
      # is a heading file and not a note file for Obsidian
      heading="${heading%.*}.h.md" 
    fi
    
    # If there is no heading, use the file name
    # Replace all dashes with spaces
    heading="${heading:-$file_name}"
    heading="${heading//-/ }"

    # If the file was snake case, replace underscores with spaces
    if [[ $heading = $file_name ]] && [[ $heading =~ '_' ]]; then
      heading="${heading//_/ }"
      heading="${heading%.*}.u.md"
    fi

    # Rename file with the heading
    if [[ $file_name = $heading ]]; then
      echo "[!] File already converted!"
    else
      mv "$file" "${file%/*}/$heading"
      echo "[!] Converted to $heading"

      # Update links in all files
      echo "[!] Updating links..."
      replace_links "$file_name" "$heading"
    fi
  done
}

# Convert all Obsidian files to Markdown format
function deobsidianize(){
  for file in "${@:1}"; do
    # Get the file original name
    file_name=$(basename -- "$file")
    heading=$file_name # starting point
    echo "[?] Converting $file_name..."

    # If it is a heading file we need to rename it to README.md; 
    if [[ $file_name =~ ^[^.]+\.h(\.u)?\.md$ ]]; then
      heading='README.md'
    fi
    
    if [[ $heading =~ \.u\.md$ ]]; then
      heading="${heading// /_}"
      heading="${heading%.*.*}.md"
    else
      heading="${heading// /-}"
    fi

    # Rename file with the heading
    if [[ $file_name = $heading ]]; then
      echo "[!] File already converted!"
    else
      mv "$file" "${file%/*}/$heading"
      echo "[!] Converted to $heading"

      # Update links in all files
      echo "[!] Updating links..."
      replace_links "$file_name" "$heading"
    fi
  done
}

# Get the directory of the current script
current_dir=$(dirname "$(readlink -f "$0")")
root_project="${current_dir%/*}"

echo "Choose an option"
echo "1. Convert files to Obsidian"
echo "2. Convert files to Markdown"

read -p "Enter your choice: " choice

case $choice in
  1)
    echo "Converting files to Obsidian..."
    files=() # markdown files to convert

    while IFS=  read -r -d $'\0'; do
      files+=("$REPLY")
    done < <(find "$root_project" -type f -name "*.md" -not -path '*/\.*/*' -print0)
    obsidianize "${files[@]}"
  ;;
  2)
    echo "Converting files to Markdown..."
    files=() # markdown files to convert

    while IFS=  read -r -d $'\0'; do
      files+=("$REPLY")
    done < <(find "$root_project" -type f -name "*.md" -not -path '*/\.*/*' -print0)

    deobsidianize "${files[@]}"
  ;;

  *)
    echo "Invalid choice"
    exit 1
  ;;
esac

