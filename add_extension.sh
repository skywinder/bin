for file in *; do
    if [[ -f "$file" && ! "$file" =~ \. ]]; then # Check if it's a regular file without an extension
        type=$(file "$file") # Get file type
        echo "Processing '$file': Detected type: $type" # Debug message
        if [[ "$type" == *"JPEG image data"* ]]; then
            mv "$file" "$file.jpg"
            echo "Renamed to '$file.jpg'"
        elif [[ "$type" == *"ISO Media, MP4"* || "$type" == *"Apple QuickTime movie"* ]]; then
            mv "$file" "$file.mp4"
            echo "Renamed to '$file.mp4'"
        elif [[ "$type" == *"Apple QuickTime movie"* ]]; then
            mv "$file" "$file.mov"
            echo "Renamed to '$file.mov'"
        else
            echo "No known extension found for '$file'"
        fi
    fi
done
