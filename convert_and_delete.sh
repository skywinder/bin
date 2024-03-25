#!/bin/bash

# Define a function to process each file
process_file() {
    local infile="$1"
    local outfile="${infile}.jpg"

    # Convert to JPG
    magick "$infile" -despeckle -quality 85 "$outfile" && echo "Converted $outfile"

    # Migrate EXIF data
    exiftool -overwrite_original_in_place -TagsFromFile "$infile" "$outfile" && echo "Migrated EXIF data from $infile to $outfile"

    # Delete original file
    rm "$infile" && echo "Deleted original file $infile"

    echo "---"
}

# Export the function so it's available in subshells
export -f process_file

# Find and process all CR2 and DNG files
find . -type f \( -iname "*.nef" -o -iname "*.cr2" -o -iname "*.dng" -o -iname "*.ARW" \) -exec bash -c 'process_file "$0"' {} \;


