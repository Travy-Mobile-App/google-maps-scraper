# Running the API Locally

## Quick Start

### 1. Start the Server

**Basic (slow - concurrency=1):**
```bash
./google-maps-scraper -web -data-folder webdata -addr :8080
```

**Recommended (faster - concurrency=8):**
```bash
./google-maps-scraper -web -data-folder webdata -addr :8080 -c 8
```

**Maximum Performance (if you have resources):**
```bash
./google-maps-scraper -web -data-folder webdata -addr :8080 -c 16
```

The server will start on `http://localhost:8080`

**Performance Tip:** Use `-c` flag to set concurrency (parallel browser tabs). Higher = faster but uses more resources. Start with `-c 8` for good balance.

### 2. Test the API

#### Option A: Use the Test Script

```bash
./test-api-local.sh
```

#### Option B: Manual Testing

**Create a Job:**
```bash
curl -X POST "http://localhost:8080/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Restaurants in NYC",
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "zoom": 15,
    "lat": "40.7128",
    "lon": "-74.0060",
    "depth": 1,
    "max_time": 300
  }'
```

**Get Job Status:**
```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}"
```

**Get Results as JSON:**
```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}/results"
```

**Download Results as CSV:**
```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}/download" --output results.csv
```

### 3. Access Web UI

Open in browser: `http://localhost:8080`

### 4. View API Documentation

Open in browser: `http://localhost:8080/api/docs`

## Example Workflow

```bash
# 1. Create a job
JOB_ID=$(curl -s -X POST "http://localhost:8080/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coffee shops",
    "keywords": ["coffee in San Francisco"],
    "lang": "en",
    "depth": 1,
    "max_time": 300
  }' | jq -r '.id')

echo "Job ID: $JOB_ID"

# 2. Check status (poll until complete)
while true; do
  STATUS=$(curl -s "http://localhost:8080/api/v1/jobs/$JOB_ID" | jq -r '.status')
  echo "Status: $STATUS"
  
  if [ "$STATUS" = "ok" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  
  sleep 5
done

# 3. Get results as JSON
curl -s "http://localhost:8080/api/v1/jobs/$JOB_ID/results" | jq

# 4. Or download as CSV
curl "http://localhost:8080/api/v1/jobs/$JOB_ID/download" --output results.csv
```

## Stop the Server

Press `Ctrl+C` in the terminal where the server is running, or:

```bash
lsof -ti:8080 | xargs kill -9
```

