#!/bin/bash

# Test script for Google Maps Scraper API (Local)
# Make sure the server is running: ./google-maps-scraper -web -data-folder webdata

BASE_URL="http://localhost:8080"

echo "=== Testing Google Maps Scraper API (Local) ==="
echo ""

# Check if server is running
if ! curl -s "$BASE_URL/api/v1/jobs" > /dev/null 2>&1; then
    echo "❌ Server is not running!"
    echo "Start it with: ./google-maps-scraper -web -data-folder webdata"
    exit 1
fi

echo "✅ Server is running"
echo ""

# Test 1: Create a job
echo "1. Creating a new scraping job..."
JOB_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Job - Restaurants in NYC",
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "zoom": 15,
    "lat": "40.7128",
    "lon": "-74.0060",
    "depth": 1,
    "max_time": 300
  }')

JOB_ID=$(echo "$JOB_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$JOB_ID" ]; then
  echo "❌ Failed to create job"
  echo "Response: $JOB_RESPONSE"
  exit 1
fi

echo "✅ Job created successfully!"
echo "   Job ID: $JOB_ID"
echo ""

# Test 2: Get job details
echo "2. Getting job details..."
JOB_DETAILS=$(curl -s -X GET "$BASE_URL/api/v1/jobs/$JOB_ID")
JOB_STATUS=$(echo "$JOB_DETAILS" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
echo "   Status: $JOB_STATUS"
echo ""

# Test 3: List all jobs
echo "3. Listing all jobs..."
JOBS_COUNT=$(curl -s -X GET "$BASE_URL/api/v1/jobs" | grep -o '"id"' | wc -l | tr -d ' ')
echo "   Total jobs: $JOBS_COUNT"
echo ""

# Test 4: Wait for job completion (with timeout)
echo "4. Waiting for job to complete (max 2 minutes)..."
TIMEOUT=120
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  JOB_DETAILS=$(curl -s -X GET "$BASE_URL/api/v1/jobs/$JOB_ID")
  JOB_STATUS=$(echo "$JOB_DETAILS" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
  
  echo "   Status: $JOB_STATUS (${ELAPSED}s elapsed)"
  
  if [ "$JOB_STATUS" = "ok" ] || [ "$JOB_STATUS" = "failed" ]; then
    break
  fi
  
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo ""

# Test 5: Get results as JSON (if job completed successfully)
if [ "$JOB_STATUS" = "ok" ]; then
  echo "5. Getting results as JSON..."
  RESULTS=$(curl -s -X GET "$BASE_URL/api/v1/jobs/$JOB_ID/results")
  RESULTS_COUNT=$(echo "$RESULTS" | grep -o '"title"' | wc -l | tr -d ' ')
  
  if [ "$RESULTS_COUNT" -gt 0 ]; then
    echo "✅ Results retrieved successfully!"
    echo "   Results count: $RESULTS_COUNT"
    echo ""
    echo "First result (preview):"
    echo "$RESULTS" | head -c 500
    echo "..."
  else
    echo "⚠️  No results found"
  fi
else
  echo "5. Skipping results (job status: $JOB_STATUS)"
fi

echo ""
echo "=== API Test Complete ==="
echo ""
echo "API Endpoints:"
echo "  - List jobs: curl $BASE_URL/api/v1/jobs"
echo "  - Get job: curl $BASE_URL/api/v1/jobs/$JOB_ID"
echo "  - Get results (JSON): curl $BASE_URL/api/v1/jobs/$JOB_ID/results"
echo "  - Download CSV: curl $BASE_URL/api/v1/jobs/$JOB_ID/download --output results.csv"
echo "  - Delete job: curl -X DELETE $BASE_URL/api/v1/jobs/$JOB_ID"
echo ""
echo "Web UI: $BASE_URL"
echo "API Docs: $BASE_URL/api/docs"

