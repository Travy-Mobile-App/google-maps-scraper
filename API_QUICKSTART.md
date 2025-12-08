# API Quick Start Guide

## Start the API Server

```bash
./google-maps-scraper -web -data-folder webdata
```

The server will start on `http://localhost:8080`

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

