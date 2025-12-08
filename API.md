# Google Maps Scraper API Documentation

Complete API documentation for the Google Maps Scraper REST API.

## Base URL

```
http://localhost:8080
```

## Authentication

Currently, the API does not require authentication. This may change in future versions.

## Endpoints

### 1. Create a Scraping Job

Create a new scraping job that will be processed asynchronously.

**Endpoint:** `POST /api/v1/jobs`

**Request Body:**
```json
{
  "name": "Restaurants in NYC",
  "keywords": ["restaurants in New York", "pizza in Manhattan"],
  "lang": "en",
  "zoom": 15,
  "lat": "40.7128",
  "lon": "-74.0060",
  "fast_mode": false,
  "radius": 10000,
  "depth": 1,
  "email": false,
  "max_time": 3600,
  "proxies": []
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Job name/description |
| `keywords` | array[string] | Yes | Search queries (one per line) |
| `lang` | string | Yes | Language code (2 characters, e.g., "en", "de", "fr") |
| `zoom` | integer | No | Zoom level (0-21, default: 15) |
| `lat` | string | No* | Latitude coordinate |
| `lon` | string | No* | Longitude coordinate |
| `fast_mode` | boolean | No | Enable fast mode (reduced data collection) |
| `radius` | integer | No | Search radius in meters (default: 10000) |
| `depth` | integer | Yes | Scroll depth (number of pages to scrape) |
| `email` | boolean | No | Extract emails from websites |
| `max_time` | integer | Yes | Maximum execution time in seconds |
| `proxies` | array[string] | No | List of proxy URLs (format: `protocol://user:pass@host:port`) |

*Required if `fast_mode` is `true`

**Response:** `201 Created`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Error Responses:**

- `422 Unprocessable Entity` - Invalid request data
- `500 Internal Server Error` - Server error

**Example:**
```bash
curl -X POST "http://localhost:8080/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coffee shops in San Francisco",
    "keywords": ["coffee in San Francisco"],
    "lang": "en",
    "zoom": 15,
    "lat": "37.7749",
    "lon": "-122.4194",
    "depth": 1,
    "max_time": 1800
  }'
```

---

### 2. List All Jobs

Get a list of all scraping jobs.

**Endpoint:** `GET /api/v1/jobs`

**Response:** `200 OK`
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Restaurants in NYC",
    "date": "2024-12-08T10:30:00Z",
    "status": "ok",
    "data": {
      "keywords": ["restaurants in New York"],
      "lang": "en",
      "zoom": 15,
      "lat": "40.7128",
      "lon": "-74.0060",
      "fast_mode": false,
      "radius": 10000,
      "depth": 1,
      "email": false,
      "max_time": 3600000000000,
      "proxies": []
    }
  }
]
```

**Job Status Values:**
- `pending` - Job is queued and waiting to be processed
- `working` - Job is currently being processed
- `ok` - Job completed successfully
- `failed` - Job failed with an error

**Example:**
```bash
curl -X GET "http://localhost:8080/api/v1/jobs"
```

---

### 3. Get Job Details

Get detailed information about a specific job.

**Endpoint:** `GET /api/v1/jobs/{id}`

**Path Parameters:**
- `id` (string, required) - Job UUID

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Restaurants in NYC",
  "date": "2024-12-08T10:30:00Z",
  "status": "ok",
  "data": {
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "zoom": 15,
    "lat": "40.7128",
    "lon": "-74.0060",
    "fast_mode": false,
    "radius": 10000,
    "depth": 1,
    "email": false,
    "max_time": 3600000000000,
    "proxies": []
  }
}
```

**Error Responses:**
- `404 Not Found` - Job not found
- `422 Unprocessable Entity` - Invalid job ID

**Example:**
```bash
curl -X GET "http://localhost:8080/api/v1/jobs/550e8400-e29b-41d4-a716-446655440000"
```

---

### 4. Download Job Results

Download the results of a completed job as a CSV file.

**Endpoint:** `GET /api/v1/jobs/{id}/download`

**Path Parameters:**
- `id` (string, required) - Job UUID

**Response:** `200 OK`
- Content-Type: `text/csv`
- Content-Disposition: `attachment; filename={job-id}.csv`

**Error Responses:**
- `404 Not Found` - Job or results file not found
- `422 Unprocessable Entity` - Invalid job ID
- `500 Internal Server Error` - Server error

**Example:**
```bash
curl -X GET "http://localhost:8080/api/v1/jobs/550e8400-e29b-41d4-a716-446655440000/download" \
  --output results.csv
```

---

### 5. Delete Job

Delete a job and its associated results file.

**Endpoint:** `DELETE /api/v1/jobs/{id}`

**Path Parameters:**
- `id` (string, required) - Job UUID

**Response:** `200 OK` (empty body)

**Error Responses:**
- `422 Unprocessable Entity` - Invalid job ID
- `500 Internal Server Error` - Server error

**Example:**
```bash
curl -X DELETE "http://localhost:8080/api/v1/jobs/550e8400-e29b-41d4-a716-446655440000"
```

---

### 6. API Documentation

View interactive API documentation using ReDoc.

**Endpoint:** `GET /api/docs`

**Response:** HTML page with interactive API documentation

**Example:**
Open in browser: `http://localhost:8080/api/docs`

---

## Error Response Format

All error responses follow this format:

```json
{
  "code": 422,
  "message": "Error description"
}
```

## Complete Example Workflow

### 1. Create a Job
```bash
JOB_ID=$(curl -s -X POST "http://localhost:8080/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Restaurants in NYC",
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "zoom": 15,
    "lat": "40.7128",
    "lon": "-74.0060",
    "depth": 1,
    "max_time": 3600
  }' | jq -r '.id')

echo "Job ID: $JOB_ID"
```

### 2. Check Job Status
```bash
curl -X GET "http://localhost:8080/api/v1/jobs/$JOB_ID" | jq '.status'
```

### 3. Wait for Completion (Polling)
```bash
while true; do
  STATUS=$(curl -s -X GET "http://localhost:8080/api/v1/jobs/$JOB_ID" | jq -r '.status')
  echo "Status: $STATUS"
  
  if [ "$STATUS" = "ok" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  
  sleep 5
done
```

### 4. Download Results
```bash
curl -X GET "http://localhost:8080/api/v1/jobs/$JOB_ID/download" \
  --output results.csv
```

### 5. Clean Up
```bash
curl -X DELETE "http://localhost:8080/api/v1/jobs/$JOB_ID"
```

## Python Example

```python
import requests
import time
import json

BASE_URL = "http://localhost:8080"

# Create a job
job_data = {
    "name": "Restaurants in NYC",
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "zoom": 15,
    "lat": "40.7128",
    "lon": "-74.0060",
    "depth": 1,
    "max_time": 3600
}

response = requests.post(f"{BASE_URL}/api/v1/jobs", json=job_data)
job_id = response.json()["id"]
print(f"Created job: {job_id}")

# Poll for completion
while True:
    response = requests.get(f"{BASE_URL}/api/v1/jobs/{job_id}")
    job = response.json()
    status = job["status"]
    print(f"Status: {status}")
    
    if status in ["ok", "failed"]:
        break
    
    time.sleep(5)

# Download results
if status == "ok":
    response = requests.get(f"{BASE_URL}/api/v1/jobs/{job_id}/download")
    with open("results.csv", "wb") as f:
        f.write(response.content)
    print("Results downloaded to results.csv")
```

## JavaScript/Node.js Example

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:8080';

async function createAndDownloadJob() {
  // Create a job
  const jobData = {
    name: 'Restaurants in NYC',
    keywords: ['restaurants in New York'],
    lang: 'en',
    zoom: 15,
    lat: '40.7128',
    lon: '-74.0060',
    depth: 1,
    max_time: 3600
  };

  const createResponse = await axios.post(`${BASE_URL}/api/v1/jobs`, jobData);
  const jobId = createResponse.data.id;
  console.log(`Created job: ${jobId}`);

  // Poll for completion
  while (true) {
    const statusResponse = await axios.get(`${BASE_URL}/api/v1/jobs/${jobId}`);
    const status = statusResponse.data.status;
    console.log(`Status: ${status}`);

    if (status === 'ok' || status === 'failed') {
      break;
    }

    await new Promise(resolve => setTimeout(resolve, 5000));
  }

  // Download results
  const downloadResponse = await axios.get(
    `${BASE_URL}/api/v1/jobs/${jobId}/download`,
    { responseType: 'stream' }
  );
  
  const fs = require('fs');
  const writer = fs.createWriteStream('results.csv');
  downloadResponse.data.pipe(writer);
  
  console.log('Results downloaded to results.csv');
}

createAndDownloadJob().catch(console.error);
```

## Rate Limiting

Currently, there is no rate limiting implemented. Be mindful of the server resources when making requests.

## Notes

- Jobs are processed asynchronously. Use polling to check job status.
- Results are stored as CSV files in the data folder.
- Jobs with status `ok` have completed successfully and results are available for download.
- Jobs with status `failed` encountered an error during processing.
- The `max_time` parameter is in seconds and should be at least 180 (3 minutes).

