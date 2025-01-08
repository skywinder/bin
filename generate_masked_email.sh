# Check if FASTMAIL_API_KEY is set
if [ -z "$FASTMAIL_API_KEY" ]; then
  echo "Error: FASTMAIL_API_KEY is not set in the environment."
  exit 1
fi

# Configurations
API_URL="https://api.fastmail.com/jmap/session"  # Updated URL to get session first
PURPOSE="$1"  # Optional: Purpose of the masked email, passed as an argument

# Dependencies check
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null || ! command -v pbcopy &>/dev/null; then
  echo "Error: This script requires 'curl', 'jq', and 'pbcopy'."
  echo "Install them using your package manager (e.g., brew for macOS)."
  exit 1
fi

# Add debug mode
DEBUG=${DEBUG:-0}

# Enhanced debugging function
debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "DEBUG: $1" >&2
    fi
}

# First get the API endpoint from the session
debug "Fetching JMAP session..."
SESSION_RESPONSE=$(curl -s -L -w "\n%{http_code}" \
    -H "Authorization: Bearer $FASTMAIL_API_KEY" \
    "$API_URL")

SESSION_HTTP_STATUS=$(echo "$SESSION_RESPONSE" | tail -n1)
SESSION_BODY=$(echo "$SESSION_RESPONSE" | sed '$ d')

debug "Session HTTP Status: $SESSION_HTTP_STATUS"
debug "Session Body: $SESSION_BODY"

if [ "$SESSION_HTTP_STATUS" -ne 200 ]; then
    echo "Error: Failed to get JMAP session with status $SESSION_HTTP_STATUS"
    debug "Full session response: $SESSION_BODY"
    exit 1
fi

# Extract the API endpoint and account ID
API_ENDPOINT=$(echo "$SESSION_BODY" | jq -r '.apiUrl')
ACCOUNT_ID=$(echo "$SESSION_BODY" | jq -r '.primaryAccounts["https://www.fastmail.com/dev/maskedemail"]')
debug "API Endpoint: $API_ENDPOINT"
debug "Account ID: $ACCOUNT_ID"

if [ -z "$API_ENDPOINT" ] || [ "$API_ENDPOINT" = "null" ]; then
    echo "Error: Failed to get API endpoint from session"
    exit 1
fi

if [ -z "$ACCOUNT_ID" ] || [ "$ACCOUNT_ID" = "null" ]; then
    echo "Error: Failed to get account ID from session"
    exit 1
fi

# More detailed API call with error capture
debug "Making masked email generation request..."
API_RESPONSE=$(curl -s -L -w "\n%{http_code}" -X POST \
    -H "Authorization: Bearer $FASTMAIL_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"using\":[\"urn:ietf:params:jmap:core\",\"https://www.fastmail.com/dev/maskedemail\"],\"methodCalls\":[[\"MaskedEmail/set\",{\"accountId\":\"$ACCOUNT_ID\",\"create\":{\"new\":{\"state\":\"enabled\"}}},\"0\"]]}" \
    "$API_ENDPOINT")

HTTP_STATUS=$(echo "$API_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$API_RESPONSE" | sed '$ d')

debug "HTTP Status: $HTTP_STATUS"
debug "Response Body: $RESPONSE_BODY"

# More detailed error checking
if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error: API request failed with status $HTTP_STATUS"
    debug "Full response: $RESPONSE_BODY"
    exit 1
fi

MASKED_EMAIL=$(echo "$RESPONSE_BODY" | jq -r '.methodResponses[0][1].created.new.email')

# Validate response
if [ -z "$MASKED_EMAIL" ] || [ "$MASKED_EMAIL" = "null" ]; then
  echo "Error: Failed to generate masked email. Please check your API key and Fastmail setup."
  debug "Response body: $RESPONSE_BODY"
  exit 1
fi

# Copy to clipboard
echo -n "$MASKED_EMAIL" | pbcopy
echo "Masked Email generated and copied to clipboard: $MASKED_EMAIL"

# Add purpose as a comment if provided
if [ -n "$PURPOSE" ]; then
  echo "Purpose: $PURPOSE"
  echo "$MASKED_EMAIL - $PURPOSE" | pbcopy
fi

exit 0
