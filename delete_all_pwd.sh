#!/bin/bash

# Check if a path argument was provided
if [ -z "$1" ]; then
    echo "No path provided. Using current directory."
    input_path=$(pwd)
else
    input_path="$1"
fi

# Extract the desired path
extracted_b2_path=$(echo "$input_path" | sed 's|^/Volumes/SunBackupSSD||')
extracted_sk_path=$(echo "$input_path" | sed 's|^/Volumes/SunBackupSSD/sk_webdav||')

# Print the size of the folders to be deleted
echo "Size of folder to be deleted from b2:SkywinderMegaSync:"
rclone size "b2:SkywinderMegaSync${extracted_b2_path}"
echo "Size of folder to be deleted from sk:"
rclone size "sk:${extracted_sk_path}"

# Use the extracted path in the rclone delete commands
rclone delete "b2:SkywinderMegaSync${extracted_b2_path}"
rclone delete "sk:${extracted_sk_path}"

# Delete the current folder as well
rm -rf "$input_path"

