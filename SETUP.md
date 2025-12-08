# Complete Setup Guide - Google Maps Scraper

This guide covers all setup steps and changes made to get the Google Maps Scraper project running from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Building the Project](#building-the-project)
4. [Running the Scraper](#running-the-scraper)
5. [Using the Search Script](#using-the-search-script)
6. [Railway Deployment](#railway-deployment)
7. [API Usage](#api-usage)

---

## Prerequisites

### 1. Install Homebrew (macOS)

If you don't have Homebrew installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Install Go

```bash
brew install go
```

Verify installation:

```bash
go version
# Should show: go version go1.25.x or similar
```

---

## Initial Setup

### 1. Navigate to Project Directory

```bash
cd /path/to/google-maps-scraper-main
```

### 2. Download Dependencies

```bash
go mod download
```

### 3. Install Playwright CLI

```bash
go install github.com/playwright-community/playwright-go/cmd/playwright@latest
```

### 4. Install Playwright Browsers

```bash
~/go/bin/playwright install chromium
```

This will download:
- Chromium browser (~125MB)
- FFMPEG (~1MB)
- Chromium Headless Shell (~80MB)

**Note**: This may take a few minutes depending on your internet connection.

---

## Building the Project

### Build the Binary

```bash
go build -o google-maps-scraper
```

This creates an executable file named `google-maps-scraper` in the current directory.

Verify the build:

```bash
ls -lh google-maps-scraper
# Should show a file around 60MB
```

### Test the Build

```bash
./google-maps-scraper -h
```

You should see the help menu with all available options.

---

## Running the Scraper

### Option 1: Command Line (Basic)

Create a query file:

```bash
echo "restaurants in New York" > queries.txt
```

Run the scraper:

```bash
./google-maps-scraper \
  -input queries.txt \
  -results results.csv \
  -depth 1 \
  -exit-on-inactivity 3m
```

### Option 2: Command Line (With Coordinates)

```bash
./google-maps-scraper \
  -input queries.txt \
  -results results.csv \
  -depth 1 \
  -geo "40.7128,-74.0060" \
  -zoom 15 \
  -exit-on-inactivity 3m
```

### Option 3: Web UI

Start the web server:

```bash
./google-maps-scraper -web -data-folder webdata
```

Then open your browser to: `http://localhost:8080`

### Option 4: JSON Output

```bash
./google-maps-scraper \
  -input queries.txt \
  -results results.json \
  -json \
  -depth 1 \
  -exit-on-inactivity 3m
```

---

## Using the Search Script

A custom script `search-ny-restaurants.sh` has been created for easy searching.

### Make Script Executable

```bash
chmod +x search-ny-restaurants.sh
```

### Edit Configuration (Optional)

Open the script and modify these variables:

```bash
# Geo coordinates (optional)
GEO_COORDINATES="40.7128,-74.0060"  # New York City
ZOOM_LEVEL=15  # Zoom level (0-21)

# Or disable coordinates:
GEO_COORDINATES=""  # Leave empty to search without coordinates
```

### Run the Script

```bash
./search-ny-restaurants.sh
```

The script will:
1. Create a query file with restaurant searches
2. Run the scraper with optimized settings
3. Save results to `ny-restaurants-results.json`
4. Display formatted JSON results when finished

### Script Features

- Automatically creates query file
- Uses JSON output format
- Limits to first page (10-20 results)
- Shows results count
- Pretty-prints JSON output
- Supports latitude/longitude coordinates

---

## Railway Deployment

### Files Created for Railway

The following files were added for Railway deployment:

1. **railway.toml** - Railway configuration
2. **railway.json** - Alternative JSON config
3. **RAILWAY_DEPLOY.md** - Detailed deployment guide
4. **RAILWAY_QUICKSTART.md** - Quick start guide
5. **.railwayignore** - Files to exclude from deployment

### Dockerfile Updates

The Dockerfile was updated to:
- Create `/app/data` directory for storing results
- Set default command for web mode
- Use `0.0.0.0` binding for Railway's PORT variable

### Deploy to Railway

#### Method 1: GitHub (Recommended)

1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Add Railway deployment configuration"
   git push origin main
   ```

2. **Connect to Railway**:
   - Go to [railway.app](https://railway.app)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository

3. **Railway will automatically**:
   - Detect the Dockerfile
   - Build the Docker image
   - Deploy the application
   - Provide a public URL

#### Method 2: Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize and deploy
railway init
railway up
```

### Environment Variables (Optional)

In Railway dashboard → Variables, you can set:

- `DISABLE_TELEMETRY=1` - Disable anonymous usage tracking

### Important Notes

1. **Port Configuration**: Railway automatically sets `PORT` environment variable. The start command uses `0.0.0.0:$PORT`.

2. **Data Persistence**: By default, data is ephemeral (lost on redeploy). To persist:
   - Add a Volume in Railway dashboard
   - Mount it to `/app/data`
   - Update start command if needed

3. **Resource Requirements**:
   - Memory: 1GB+ (Playwright browsers need memory)
   - Storage: 5GB+ recommended
   - CPU: 1 vCPU minimum

---

## API Usage

### Start API Server Locally

```bash
./google-maps-scraper -web -data-folder webdata -addr :8080
```

### API Endpoints

#### 1. Create a Scraping Job

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
{
  "id": "job-uuid-here"
}
```

#### 2. List All Jobs

```bash
curl -X GET "http://localhost:8080/api/v1/jobs"
```

#### 3. Get Job Details

```bash
curl -X GET "http://localhost:8080/api/v1/jobs/{job-id}"
```

#### 4. Download Results

```bash
curl -X GET "http://localhost:8080/api/v1/jobs/{job-id}/download" \
  --output results.csv
```

#### 5. Delete Job

```bash
curl -X DELETE "http://localhost:8080/api/v1/jobs/{job-id}"
```

#### 6. API Documentation

Visit: `http://localhost:8080/api/docs`

### API Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Job name |
| `keywords` | array | Yes | Search queries |
| `lang` | string | Yes | Language code (2 chars) |
| `zoom` | integer | No | Zoom level (0-21) |
| `lat` | string | No* | Latitude |
| `lon` | string | No* | Longitude |
| `fast_mode` | boolean | No | Enable fast mode |
| `radius` | integer | No | Search radius in meters |
| `depth` | integer | Yes | Scroll depth (pages) |
| `email` | boolean | No | Extract emails |
| `max_time` | integer | Yes | Max time in seconds |
| `proxies` | array | No | Proxy list |

*Required if `fast_mode` is true

---

## Common Command Line Options

### Basic Options

```bash
-input string          # Path to input file with queries
-results string        # Path to results file (default: stdout)
-depth int             # Maximum scroll depth (default: 10)
-c int                 # Concurrency (default: half of CPU cores)
-lang string           # Language code (default: "en")
-exit-on-inactivity    # Exit after inactivity (e.g., "3m")
```

### Output Options

```bash
-json                  # Produce JSON output instead of CSV
-email                 # Extract emails from websites
-extra-reviews         # Enable extra reviews collection
```

### Location Options

```bash
-geo string            # Geo coordinates (e.g., "37.7749,-122.4194")
-zoom int              # Zoom level (0-21, default: 15)
-radius float           # Search radius in meters (default: 10000)
```

### Web Server Options

```bash
-web                   # Run web server instead of crawling
-data-folder string    # Data folder for web runner (default: "webdata")
-addr string           # Address to listen on (default: ":8080")
```

### Advanced Options

```bash
-fast-mode             # Fast mode (reduced data collection)
-proxies string         # Comma-separated list of proxies
-debug                 # Enable headful crawl (opens browser window)
-disable-page-reuse    # Disable page reuse in playwright
```

---

## Troubleshooting

### Issue: "command not found: go"

**Solution**: Install Go using Homebrew:
```bash
brew install go
```

### Issue: Playwright browsers not found

**Solution**: Install Playwright browsers:
```bash
go install github.com/playwright-community/playwright-go/cmd/playwright@latest
~/go/bin/playwright install chromium
```

### Issue: Build fails

**Solution**: 
1. Ensure you're using Go 1.24.6 or higher
2. Run `go mod download` to fetch dependencies
3. Check `go.mod` for correct module path

### Issue: Port already in use

**Solution**: Use a different port:
```bash
./google-maps-scraper -web -addr :8081
```

### Issue: No results returned

**Solution**:
1. Check your query file has valid queries
2. Increase `-depth` to scrape more pages
3. Check internet connection
4. Try without coordinates first

### Issue: Railway deployment fails

**Solution**:
1. Check Railway build logs
2. Verify Dockerfile is in root directory
3. Ensure `railway.toml` is correct
4. Check memory limits (may need to upgrade plan)

---

## File Structure

After setup, your project should have:

```
google-maps-scraper-main/
├── google-maps-scraper          # Built binary (after build)
├── search-ny-restaurants.sh     # Custom search script
├── railway.toml                 # Railway configuration
├── railway.json                 # Alternative Railway config
├── Dockerfile                   # Updated for Railway
├── .railwayignore              # Railway ignore file
├── SETUP_GUIDE.md              # This file
├── RAILWAY_DEPLOY.md           # Railway deployment guide
├── RAILWAY_QUICKSTART.md       # Railway quick start
├── go.mod                      # Go dependencies
├── main.go                     # Main entry point
└── ... (other project files)
```

---

## Quick Reference

### Build and Run Locally

```bash
# 1. Install dependencies
go mod download

# 2. Install Playwright
go install github.com/playwright-community/playwright-go/cmd/playwright@latest
~/go/bin/playwright install chromium

# 3. Build
go build -o google-maps-scraper

# 4. Run
./google-maps-scraper -web -data-folder webdata
```

### Run Search Script

```bash
chmod +x search-ny-restaurants.sh
./search-ny-restaurants.sh
```

### Deploy to Railway

```bash
# Push to GitHub
git add .
git commit -m "Ready for deployment"
git push origin main

# Then connect repo in Railway dashboard
```

---

## Next Steps

1. ✅ Project is set up and ready to use
2. ✅ Test locally with the search script
3. ✅ Deploy to Railway for production use
4. ✅ Use the API endpoints for programmatic access
5. ✅ Customize queries and parameters as needed

---

## Support

- **Documentation**: See `README.md` for original project documentation
- **Railway Deployment**: See `RAILWAY_DEPLOY.md` for detailed Railway guide
- **API Documentation**: Visit `/api/docs` when web server is running
- **GitHub**: Check the original repository for issues and updates

---

**Last Updated**: Based on setup changes made during initial project configuration.

