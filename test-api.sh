#!/bin/bash

# Test script for Google Maps Scraper API
# Make sure the server is running: ./google-maps-scraper -web -data-folder webdata

BASE_URL="http://localhost:8080"

echo "=== Testing Google Maps Scraper API ==="
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
    "max_time": 600
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

# Test 5: Download results (if job completed successfully)
if [ "$JOB_STATUS" = "ok" ]; then
  echo "5. Downloading results..."
  curl -s -X GET "$BASE_URL/api/v1/jobs/$JOB_ID/download" \
    --output "test-results-$JOB_ID.csv"
  
  if [ -f "test-results-$JOB_ID.csv" ]; then
    LINE_COUNT=$(wc -l < "test-results-$JOB_ID.csv" | tr -d ' ')
    echo "✅ Results downloaded successfully!"
    echo "   File: test-results-$JOB_ID.csv"
    echo "   Lines: $LINE_COUNT"
  else
    echo "❌ Failed to download results"
  fi
else
  echo "5. Skipping download (job status: $JOB_STATUS)"
fi

echo ""
echo "=== API Test Complete ==="
echo ""
echo "To clean up, delete the job:"
echo "  curl -X DELETE $BASE_URL/api/v1/jobs/$JOB_ID"

