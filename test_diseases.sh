#!/bin/bash
# Test Disease Labels API Endpoint

BACKEND_URL="http://192.168.1.122:4000/api"
TOKEN="$1"  # Pass JWT token as argument

echo "=== Testing Disease Labels Endpoint ==="
echo "Backend URL: $BACKEND_URL"
echo ""

if [ -z "$TOKEN" ]; then
    echo "ERROR: No JWT token provided"
    echo "Usage: bash test_diseases.sh <JWT_TOKEN>"
    echo ""
    echo "Get token by running:"
    echo '  curl -X POST http://192.168.1.122:4000/api/auth/login \'
    echo '    -H "Content-Type: application/json" \'
    echo "    -d '{\"email\":\"test@example.com\",\"password\":\"password123\"}'"
    exit 1
fi

echo "Making request to: $BACKEND_URL/disease-labels"
echo "Authorization: Bearer $TOKEN"
echo ""

# Test endpoint
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BACKEND_URL/disease-labels")

# Split response and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "HTTP Status Code: $HTTP_CODE"
echo ""
echo "Response Body:"
echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ SUCCESS: Endpoint is working!"
    COUNT=$(echo "$BODY" | jq 'if type == "array" then length elif .data then (.data | length) else 0 end' 2>/dev/null || echo "0")
    echo "Diseases found: $COUNT"
else
    echo "✗ FAILED: HTTP $HTTP_CODE"
fi
