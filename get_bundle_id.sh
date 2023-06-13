#!/bin/bash

# Check if a path was provided
if [ -z "$1" ]
then
    echo "Please provide a path to the app."
    exit 1
fi

# Check if the app exists at the given path
if [ ! -d "$1" ]
then
    echo "No app found at the given path."
    exit 1
fi

# Path to the Info.plist file
plist_path="$1/Contents/Info.plist"

# Check if the Info.plist file exists
if [ ! -f "$plist_path" ]
then
    echo "No Info.plist file found in the app bundle."
    exit 1
fi

# Convert the plist to xml1 and extract the bundle identifier
bundle_id=$(plutil -convert xml1 -o - "$plist_path" | awk -F '[<>]' '/CFBundleIdentifier/{getline; print $3}')

# Check if a bundle identifier was found
if [ -z "$bundle_id" ]
then
    echo "No bundle identifier found in the Info.plist file."
    exit 1
fi

# Output the bundle identifier
echo $bundle_id

exit 0

