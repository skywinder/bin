#!/bin/sh
launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
launchctl unload /System/Library/LaunchAgents/com.apple.nsurlsessiond.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlsessiond.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.nsurlstoraged.plist
