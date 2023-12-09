#!/bin/sh
set -e

# Replace all links to a file with a new name
# $1: file name to replace
# $2: new file name
replace_links() {
  escaped_file_name=$(echo "$1" | sed 's#[^^]#[&]#g; s#\^#\\^#g')
  escaped_heading=$(echo "$2" | sed 's#[\&]#\\&#g')

  find "$root_project" \
    -type f \
    -name "*.md" \
    -not -path '*/\.*/*' \
    -print0 \
    | xargs -0 sed -i "s/$(echo "$1" | sed 's/\s/%20/gI')/$(echo "$2" | sed 's/\s/%20/g')/gI"
}

# Convert all markdown files to Obsidian format 
# using the first # heading as the file name for graphs
# (replacing spaces instead of dashes or underscores)
obsidianize() {
  # Get the file original name
  file="$1" # file to convert
  file_name=$(basename -- "$file")
  heading= # new heading of the file

  echo "[?] Converting $file_name..."

  # Replace README.md with first # heading in file; 
  if [ $file_name = "README.md" ]; then
    heading=$(sed -En '1s/(^|[[:space:]]+)#\s//p' "$file")

    # we use a prefix .h to indicate that this 
    # is a heading file and not a note file for Obsidian
    heading="${heading%.*}.h.md" 
  fi

  # If there is no heading, use the file name
  # Replace all dashes with spaces
  heading="${heading:-$file_name}"
  heading="$(echo "$heading" | sed 's/-/ /g')"

  # If the file was snake case, replace underscores with spaces
  if [ "$heading" = "$file_name" ] && echo "$heading" | grep -q '_'; then
    heading="$(echo "$heading" | sed 's/_/ /g')"
    heading="${heading%.*}.u.md"
  fi

  # Rename file with the heading
  if [ "$file_name" = "$heading" ]; then
    echo "[!] File already converted!"
  else
    mv "$file" "${file%/*}/$heading"
    echo "[!] Converted to $heading"

    # Update links in all files
    echo "[!] Updating links..."
    replace_links "$file_name" "$heading"
  fi
}

# Convert all Obsidian files to Markdown format
deobsidianize(){
  # Get the file original name
  file="$1"
  file_name=$(basename -- "$file")
  heading=$file_name # starting point
  echo "[?] Converting $file_name..."

  # If it is a heading file we need to rename it to README.md; 
  if echo "$file_name" | grep -Eq '^[^.]+\.h(\.u)?\.md$'; then
    heading='README.md'
  fi
  
  if echo "$heading" | grep -Eq '\.u\.md$'; then
    heading="$(echo "$heading" | sed 's/\s/_/g')"
    heading="${heading%.*.*}.md"
  else
    heading="$(echo "$heading" | sed 's/\s/-/g')"
  fi

  # Rename file with the heading
  if [ "$file_name" = "$heading" ]; then
    echo "[!] File already converted!"
  else
    mv "$file" "${file%/*}/$heading"
    echo "[!] Converted to $heading"

    # Update links in all files
    echo "[!] Updating links..."
    replace_links "$file_name" "$heading"
  fi
}

# Get the directory of the current script
current_dir=$(dirname "$(readlink -f "$0")")
root_project="${current_dir%/*}"

choice=${1:-}

if [ -z $choice ]; then
  echo "Choose an option"
  echo "1. Convert files to Obsidian"
  echo "2. Convert files to Markdown"

  printf 'Enter your choice: '
  read -r choice
fi

case $choice in
  1)
    echo "Converting files to Obsidian..."

    find "$root_project" \
      -type f \
      -name "*.md" \
      -not -path '*/\.*/*' \
      -print |

    while IFS= read -r REPLY; do
      echo "[?] Converting $REPLY..."
      obsidianize "$REPLY"
    done;
  ;;
  2)
    echo "Converting files to Markdown..."

    find "$root_project" \
      -type f \
      -name "*.md" \
      -not -path '*/\.*/*' \
      -print |

    while IFS=  read -r REPLY; do
      deobsidianize "$REPLY"
    done

  ;;

  *)
    echo "Invalid choice"
    exit 1
  ;;
esac

