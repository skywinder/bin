#!/bin/bash

# Initialize variables
delete=0
duration=""

# Process all arguments
while (( "$#" )); do
  case "$1" in
    -d)
      delete=1
      shift
      ;;
    -*|--*=) # Unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # Presume it's the duration if not a flag
      if [[ -z "$duration" ]]; then
        duration=$1
      else
        echo "Error: Multiple durations specified" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# Check if duration was set
if [[ -z "$duration" ]]; then
  echo "Usage: $0 [-d] <duration in seconds>"
  exit 1
fi

MAX_DURATION=$duration

find . -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \) -exec sh -c '
file="$0"
duration=$(ffmpeg -i "$file" 2>&1 | grep Duration | awk "{print \$2}" | tr -d , | awk -F: "{print (\$1*3600+\$2*60+\$3)}")
if [ $(echo "$duration < '"$MAX_DURATION"'" | bc) -eq 1 ]; then
  size_bytes=$(stat -f "%z" "$file") # Get size in bytes
  size_mb=$(echo "scale=2; $size_bytes/1024/1024" | bc) # Convert bytes to megabytes
  echo "$file - Duration: $duration seconds, Size: $size_mb MB"
  if [ '"$delete"' -eq 1 ]; then
    echo "Deleting $file..."
    rm -f "$file"
  fi
fi
' {} \;

