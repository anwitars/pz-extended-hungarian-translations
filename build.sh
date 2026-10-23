#!/usr/bin/env bash

# This script merges the translations and creates the mod used by the game.

set -e

VERBOSE=false
KEEP_TEMP=false

while getopts "vk" opt; do
  case $opt in
    v)
      VERBOSE=true
      ;;
    k)
      KEEP_TEMP=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

shift "$((OPTIND - 1))"

if [ $# -ne 1 ]; then
  echo "Usage: $0 [-v] [-k] <output_archive>" >&2
  exit 1
fi

OUTPUT_ARCHIVE="$1"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to run this script. Please install it and try again." >&2
  exit 1
elif $VERBOSE; then
  echo "[ COMMAND CHECK ] jq is installed."
fi

# accepts a <to_merge> and <to_merge_to> as arguments
# if <to_merge_to> does not exists, create a json file with an empty object
# if exists, put all the keys from <to_merge> into <to_merge_to>
merge_to_file() {
    mkdir -p "$(dirname "$2")"
    if [ ! -f "$2" ]; then
        echo "{}" > "$2"
    fi
    jq -s '.[0] * .[1]' "$1" "$2" > "$2.tmp"
    mv "$2.tmp" "$2"
}

if $VERBOSE; then
  echo "Creating temporary directory..."
fi
TEMP_DIR=$(mktemp -d)
if $VERBOSE; then
  echo "Temporary directory: $TEMP_DIR"
fi

FINAL_DIR="$TEMP_DIR/ExtendedHungarianTranslations"
mkdir -p "$FINAL_DIR"
if $VERBOSE; then
  echo "Final directory: $FINAL_DIR"
fi

if $VERBOSE; then
  echo "Merging translations..."
fi
for file in $(find translations -name '*.json'); do
    target_file=$(echo "$file" | cut -d '/' -f 3-)
    merge_to_file "$file" "$FINAL_DIR/$target_file"
done

if $VERBOSE; then
  echo "Copying mod.info..."
fi
mkdir -p "$FINAL_DIR/42"
cp mod.info "$FINAL_DIR/42"
cp preview.png "$FINAL_DIR/42/poster.png"

if $VERBOSE; then
  echo "Creating archive..."
fi
tar -C "$TEMP_DIR" -czf "$OUTPUT_ARCHIVE" .

if ! $KEEP_TEMP; then
  if $VERBOSE; then
    echo "Cleaning up..."
  fi
  rm -rf "$TEMP_DIR"
fi

if $VERBOSE; then
  echo "Done"
fi
