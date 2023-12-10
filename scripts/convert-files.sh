#!/bin/sh

# Replace all links to a file with a new name
# $1: file name to replace
# $2: new file name
replace_links() {
  tmp_file="$(mktemp -p "$PWD")"

  find "." \
    -type f \
    -name "*.md" \
    -not -path '*/\.*/*' \
    -print > "$tmp_file"

  while IFS=  read -r 'file'; do
    echo "[!] Updating links for $file..."
    
    tmp_links="$(mktemp -p "$PWD")"
    grep -Eo '[^!]\[[^]]+\]\([^)]+\)' "$file" > "$tmp_links"

    while IFS=  read -r 'link'; do
      link="${link%)}"
      link="${link#*](}"
      raw_link="$link"

      if echo "$link" | grep -q "^/"; then
        link="${PWD}${link}" # scope del root
      elif echo "$link" | grep -q "^."; then
        link="${file%/*}/${link}" # scope del file
      else
        continue # not local
      fi

      link="$(readlink -f "$link")"
      link="$(dirname "$link")"

      if [ "$link" != "$(readlink -f "$1")" ]; then
        continue # not the same file
      fi

      encoded_search="$(echo "$raw_link" | sed 's/\s/%20/g ; s/[^^]/[&]/g ; s/\^/\\^/g')"
      
      # el name del raw link se remplaza con el rename para encodear
      encoded_search_name="$(echo "$2" | sed 's/\s/%20/g;s/[^^]/[&]/g;s/\^/\\^/g')"
      encoded_replace_rename="$(echo "$3" | sed 's/[\&/]/\\&/g;s/\s/%20/g')"

      new_link="$(echo "$raw_link" | sed "s/$encoded_search_name/$encoded_replace_rename/g")"

      encoded_replace_new_link="$(echo "$new_link" | sed 's/[\&/]/\\&/g')"
      sed -i -E "s/$encoded_search/$encoded_replace_new_link/g" "$file"
    done < "$tmp_links"
    rm -rf "$tmp_links"
  done < "$tmp_file"
  rm -rf "$tmp_file"
}

# Convert all markdown files to Obsidian format 
# using the first # heading as the file name for graphs
# (replacing spaces instead of dashes or underscores)
obsidianize() {
  # Get the file original name
  file="$1" # file to convert
  file_dir="$(dirname -- "$file")"
  file_name="$(basename -- "$file")"
  heading= # new heading of the file

  echo "[?] Converting $file_name..."

  # Replace README.md with first # heading in file; 
  if [ "$file_name" = "README.md" ]; then
    heading=$(sed -En '1,/#/ s/(^|[[:space:]]+)#\s//p' "$file")

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
    replace_links "$file_dir" "$file_name" "$heading"
  fi
}

# Convert all Obsidian files to Markdown format
deobsidianize(){
  # Get the file original name
  file="$1"
  file_dir="$(dirname -- "$file")"
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
    replace_links "$file_dir" "$file_name" "$heading"
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

