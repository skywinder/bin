#!/bin/bash

# Navigate to the desired directory
cd /path/to/your/directory

# Find all files and loop through them
find . -type f | while read file; do
    # Extract filename and directory
    dir=$(dirname "${file}")
    filename=$(basename "${file}")
    
    # Skip files that are already in the current directory
    if [ "$dir" = "." ]; then
        continue
    fi
    
    # Check if the file already exists in the current directory
    if [ -e "./$filename" ]; then
        # Create a unique filename to avoid overwriting
        base=$(basename "$filename" .${filename##*.})
        extension=${filename##*.}
        counter=1
        newFilename="${base}_${counter}.${extension}"
        while [ -e "./$newFilename" ]; do
            let counter++
            newFilename="${base}_${counter}.${extension}"
        done
        mv "$file" "./$newFilename"
        echo "Moved $file to ./$newFilename"
    else
        # If no duplicate, move the file to the current directory
        mv "$file" .
        echo "Moved $file to ."
    fi
done

