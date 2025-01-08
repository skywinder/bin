#!/bin/bash

# Check if --delete flag is provided
delete_files=false
if [[ "$1" == "--delete" ]]; then
  delete_files=true
  shift
fi

# Set the folder to process files. Default is the current directory.
input_dir="${1:-.}"

# Create a new directory for processed files within the input directory
output_dir="$input_dir/processed_videos"
mkdir -p "$output_dir"

# Define a function to process each file
process_file() {
  file="$1"
  output_file="$output_dir/${file%.MP4}_processed.mp4"
  
  # Skip if output file already exists
  if [[ -e "$output_file" ]]; then
    echo "Skipping $file, processed file already exists: $output_file"
    
    # If --delete flag is set, delete the original file
    if [[ "$delete_files" == true ]]; then
      echo "Deleting original file: $file"
      rm "$file"
    fi
    return
  fi

  echo "Processing file: $file"

  # Get the original modification date of the file
  original_mod_time=$(stat -f "%Sm" -t "%Y%m%d%H%M.%S" "$file")

  # Get video track info and filter for video streams only
  track_info=$(ffmpeg -i "$file" 2>&1 | grep -E 'Stream.*Video')

  # Log track info for debugging purposes
  echo "Track info for $file:"
  echo "$track_info"

  # Extract resolution information
  res_0=$(echo "$track_info" | grep 'Stream #0:0' | awk -F'[ ,]' '{for(i=1;i<=NF;i++) if ($i ~ /[0-9]{3,}x[0-9]{3,}/) print $i}')
  res_1=$(echo "$track_info" | grep 'Stream #0:1' | awk -F'[ ,]' '{for(i=1;i<=NF;i++) if ($i ~ /[0-9]{3,}x[0-9]{3,}/) print $i}')

  # If only one video stream exists, skip the second resolution check
  if [[ -z "$res_1" ]]; then
    echo "Only one video stream found. Using the first video stream."
    stream_to_keep="0:0"
    chosen_resolution="$res_0"
  else
    # Compare the resolutions (based on width)
    width_0=$(echo "$res_0" | cut -d'x' -f1)
    width_1=$(echo "$res_1" | cut -d'x' -f1)

    if [[ "$width_0" -gt "$width_1" ]]; then
      stream_to_keep="0:0"
      chosen_resolution="$res_0"
    else
      stream_to_keep="0:1"
      chosen_resolution="$res_1"
    fi
  fi

  # Check if the file has an audio track
  audio_exists=$(ffmpeg -i "$file" 2>&1 | grep -E 'Stream.*Audio')

  # Log the chosen track and resolution
  echo "Chosen track to keep: $stream_to_keep (Resolution: $chosen_resolution)"

  # Map the higher resolution video and check for audio
  if [[ -n "$audio_exists" ]]; then
    echo "Audio track found, including audio."
    ffmpeg -i "$file" -map "$stream_to_keep" -map 0:a -c copy "$output_file"
  else
    echo "No audio track found, processing video only."
    ffmpeg -i "$file" -map "$stream_to_keep" -c copy "$output_file"
  fi

  # Set the modification time of the processed file to match the original file
  touch -t "$original_mod_time" "$output_file"

  echo "File processed: $output_file"

  # If --delete flag is set, delete the original file after successful processing
  if [[ "$delete_files" == true ]]; then
    echo "Deleting original file: $file"
    rm "$file"
  fi
}

# Loop through all MP4 files (both .mp4 and .MP4) in the specified directory and process them
for file in "$input_dir"/*.mp4 "$input_dir"/*.MP4; do
  if [[ ! -e "$file" ]]; then
    continue
  fi

  # Process the file
  process_file "$file"
done

echo "Batch processing completed."

# Open the output folder in Finder
open "$output_dir"
