#!/bin/bash

# Test script for messaging service endpoints
# This script tests the local messaging service using the JSON examples from README.md

BASE_URL="http://localhost:8080"
CONTENT_TYPE="Content-Type: application/json"

echo "=== Testing Messaging Service Endpoints ==="
echo "Base URL: $BASE_URL"
echo

# Test 1: Send SMS
echo "1. Testing SMS send..."
curl -X POST "$BASE_URL/api/v1/messages/sms" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "+12016661234",
    "to": "+18045551234",
    "type": "sms",
    "body": "Hello! This is a test SMS message.",
    "attachments": null,
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 2: Send MMS
echo "2. Testing MMS send..."
curl -X POST "$BASE_URL/api/v1/messages/sms" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "+12016661234",
    "to": "+18045551234",
    "type": "mms",
    "body": "Hello! This is a test MMS message with attachment.",
    "attachments": ["https://example.com/image.jpg"],
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 3: Send Email
echo "3. Testing Email send..."
curl -X POST "$BASE_URL/api/v1/messages/email" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "user@usehatchapp.com",
    "to": "contact@gmail.com",
    "body": "Hello! This is a test email message with <b>HTML</b> formatting.",
    "attachments": ["https://example.com/document.pdf"],
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 4: Simulate incoming SMS webhook
echo "4. Testing incoming SMS webhook..."
curl -X POST "$BASE_URL/api/v1/webhooks/sms" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "+18045551234",
    "to": "+12016661234",
    "type": "sms",
    "messaging_provider_id": "message-1",
    "body": "This is an incoming SMS message",
    "attachments": null,
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 5: Simulate incoming MMS webhook
echo "5. Testing incoming MMS webhook..."
curl -X POST "$BASE_URL/api/v1/webhooks/sms" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "+18045551234",
    "to": "+12016661234",
    "type": "mms",
    "messaging_provider_id": "message-2",
    "body": "This is an incoming MMS message",
    "attachments": ["https://example.com/received-image.jpg"],
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 6: Simulate incoming Email webhook
echo "6. Testing incoming Email webhook..."
curl -X POST "$BASE_URL/api/v1/webhooks/email" \
  -H "$CONTENT_TYPE" \
  -d '{
    "from": "contact@gmail.com",
    "to": "user@usehatchapp.com",
    "xillio_id": "message-3",
    "body": "<html><body>This is an incoming email with <b>HTML</b> content</body></html>",
    "attachments": ["https://example.com/received-document.pdf"],
    "timestamp": "2024-11-01T14:00:00Z"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test 7: Get conversations
echo "7. Testing get conversations..."
curl -X GET "$BASE_URL/api/v1/conversations" \
  -H "$CONTENT_TYPE" \
  -w "\nStatus: %{http_code}\n\n"

# Determine a conversation ID dynamically
CONV_JSON=$(curl -s -X GET "$BASE_URL/api/v1/conversations" -H "$CONTENT_TYPE")
if command -v jq >/dev/null 2>&1; then
  CONV_ID=$(printf '%s' "$CONV_JSON" | jq -r '.[0].id // empty')
else
  # Fallback: regex the first numeric id field
  CONV_ID=$(printf '%s' "$CONV_JSON" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n1)
fi

if [ -z "$CONV_ID" ]; then
  echo "No conversations found; creating one via SMS..."
  curl -s -X POST "$BASE_URL/api/v1/messages/sms" \
    -H "$CONTENT_TYPE" \
    -d '{
      "from": "+12016661234",
      "to": "+18045551234",
      "type": "sms",
      "body": "Bootstrap conversation",
      "attachments": null,
      "timestamp": "2024-11-01T14:00:00Z"
    }' >/dev/null
  CONV_JSON=$(curl -s -X GET "$BASE_URL/api/v1/conversations" -H "$CONTENT_TYPE")
  if command -v jq >/dev/null 2>&1; then
    CONV_ID=$(printf '%s' "$CONV_JSON" | jq -r '.[0].id // empty')
  else
    CONV_ID=$(printf '%s' "$CONV_JSON" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n1)
  fi
fi

echo "Using conversation ID: ${CONV_ID:-unknown}"

# Test 8: Get messages for a conversation (dynamic conversation ID)
echo "8. Testing get messages for conversation..."
curl -X GET "$BASE_URL/api/v1/conversations/${CONV_ID:-1}/messages" \
  -H "$CONTENT_TYPE" \
  -w "\nStatus: %{http_code}\n\n"

echo "=== Test script completed ===" 
