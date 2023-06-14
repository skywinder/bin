#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]
then
    echo "Please provide an app name or path."
    exit 1
fi

# If the argument is a directory, it's a path to the app
if [ -d "$1" ]
then
    app_path="$1"
else
    # If it's not a directory, consider it an app name and find its path
    app_name="$1"
    app_path=$(find /Applications -iname "*$app_name*.app" -type d -maxdepth 3 | head -n 1)
    if [ -z "$app_path" ]
    then
        echo "No app named '$app_name' found in the /Applications directory."
        exit 1
    fi
fi

# Path to the Info.plist file
plist_path="$app_path/Contents/Info.plist"

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
