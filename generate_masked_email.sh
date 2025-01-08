#!/bin/bash

# Check if FASTMAIL_API_KEY is set
if [ -z "$FASTMAIL_API_KEY" ]; then
  echo "Error: FASTMAIL_API_KEY is not set in the environment."
  exit 1
fi

# Configurations
API_URL="https://api.fastmail.com/jmap/"
PURPOSE="$1"  # Optional: Purpose of the masked email, passed as an argument

# Dependencies check
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null || ! command -v xclip &>/dev/null; then
  echo "Error: This script requires 'curl', 'jq', and 'xclip'."
  echo "Install them using your package manager (e.g., apt, brew, or yum)."
  exit 1
fi

# Generate masked email
MASKED_EMAIL=$(curl -s -X POST -H "Authorization: Bearer $FASTMAIL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"using":["urn:ietf:params:jmap:core","https://www.fastmail.com/dev/maskedemail"],"methodCalls":[["MaskedEmail/generate",{},"0"]]}' \
  "$API_URL" | jq -r '.methodResponses[0][1].maskedEmail.email')

# Validate response
if [ -z "$MASKED_EMAIL" ] || [ "$MASKED_EMAIL" == "null" ]; then
  echo "Error: Failed to generate masked email. Please check your API key and Fastmail setup."
  exit 1
fi

# Copy to clipboard
echo -n "$MASKED_EMAIL" | xclip -selection clipboard
echo "Masked Email generated and copied to clipboard: $MASKED_EMAIL"

# Add purpose as a comment if provided
if [ -n "$PURPOSE" ]; then
  echo "Purpose: $PURPOSE"
  echo "$MASKED_EMAIL - $PURPOSE" | xclip -selection clipboard
fi

exit 0
