# API Quick Start Guide

## Start the API Server

```bash
# Basic (default concurrency)
./google-maps-scraper -web -data-folder webdata

# With higher concurrency for better performance
./google-maps-scraper -web -data-folder webdata -c 4
```

The server will start on `http://localhost:8080`

**Performance Tip:** Use `-c` flag to set concurrency (number of parallel browser tabs). Default is `CPU cores / 2`. For better performance, try `-c 4` or `-c 8`.

## Quick Examples

### Create a Job

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
    "max_time": 3600
  }'
```

Response:
```json
{"id": "550e8400-e29b-41d4-a716-446655440000"}
```

### Check Job Status

```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}"
```

### Download Results (CSV)

```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}/download" --output results.csv
```

### Get Results (JSON)

```bash
curl "http://localhost:8080/api/v1/jobs/{job-id}/results"
```

### List All Jobs

```bash
curl "http://localhost:8080/api/v1/jobs"
```

### Delete a Job

```bash
curl -X DELETE "http://localhost:8080/api/v1/jobs/{job-id}"
```

## Test the API

Run the test script:

```bash
./test-api.sh
```

## Use Python Client

```bash
python3 examples/api-client.py
```

## View API Documentation

Open in browser: `http://localhost:8080/api/docs`

## Full Documentation

See [API.md](API.md) for complete API documentation.

