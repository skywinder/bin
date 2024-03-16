#!/bin/bash

# Log file
log_file="$HOME/rclone_delete.log"

# Check if a path argument was provided
if [ -z "$1" ]; then
    echo "No path provided. Using current directory." | tee -a "$log_file"
    input_path=$(pwd)
else
    input_path="$1"
fi

# Extract the desired path
extracted_b2_path=$(echo "$input_path" | sed 's|^/Volumes/SunBackupSSD||')

# Print the size of the folders to be deleted
remote_size=$(rclone size "b2:SkywinderMegaSync${extracted_b2_path}" | awk '/Total size:/ {print $3 " " $4}')
local_size=$(du -sh "$input_path" | awk '{print $1}')
echo "Size of folder to be deleted from b2:SkywinderMegaSync: $remote_size" | tee -a "$log_file"
echo "Size of local folder: $local_size" | tee -a "$log_file"

# Ask for confirmation before deleting
read -p "Are you sure you want to delete the remote and local folders? (y/n) " confirmation
if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
    echo "Deletion cancelled." | tee -a "$log_file"
    exit 0
fi

# Use the extracted path in the rclone delete command
echo "Deleting from b2:SkywinderMegaSync..." | tee -a "$log_file"
rclone delete "b2:SkywinderMegaSync${extracted_b2_path}" | tee -a "$log_file"

# Delete the current folder as well
echo "Deleting local folder: $input_path" | tee -a "$log_file"
rm -rf "$input_path" | tee -a "$log_file"



