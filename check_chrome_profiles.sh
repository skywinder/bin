#!/bin/bash

case "$(uname -s)" in

Darwin)
  CHROME_FOLDER="$HOME/Library/Application Support/Google/Chrome"
  ;;
Linux)
  CHROME_FOLDER="$HOME/.config/google-chrome"
  ;;
CYGWIN* | MINGW32* | MSYS* | MINGW*)
  CHROME_FOLDER="$HOME/AppData/Local/Google/Chrome"
  ;;
*)
  echo "Unsupported platform"
  exit 1
  ;;

esac

cat "$CHROME_FOLDER/Local State" |
  jq -r ".profile.info_cache | to_entries[] | {profile: .key, name: .value.name, user_name: .value.user_name}"
