#!/bin/bash

# Define a function to process each file
process_file() {
    local infile="$1"
    local outfile="${infile%.*}.jpg"

    # Convert to JPG
    magick "$infile" -despeckle -colorspace sRGB -quality 85 "$outfile" && echo "Converted $infile to $outfile"
    # Migrate EXIF data
    exiftool -overwrite_original_in_place -TagsFromFile "$infile" "$outfile" && echo "Migrated EXIF data from $infile to $outfile"

    # Delete original file
    rm "$infile" && echo "Deleted original file $infile"
}

# Find and process all CR2 and DNG files
find . -type f \( -iname "*.cr2" -o -iname "*.dng" \) -exec bash -c 'process_file "$0"' {} \;

