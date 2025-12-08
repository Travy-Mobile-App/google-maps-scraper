# Railway Deployment Guide

This guide will help you deploy the Google Maps Scraper to Railway.

## ✅ What's Already Configured

The project is now ready for Railway deployment with:

1. **Dockerfile** - Multi-stage build with Playwright support
2. **railway.toml** - Railway configuration file
3. **PORT environment variable support** - Automatically uses Railway's PORT
4. **Default web mode** - Starts in web server mode by default
5. **Data persistence** - Uses `/app/data` directory

## 🚀 Quick Deploy

### Option 1: Deploy from GitHub (Recommended)

1. **Push your code to GitHub** (if not already):
   ```bash
   git add .
   git commit -m "Configure Railway deployment"
   git push origin main
   ```

2. **Connect to Railway**:
   - Go to [railway.app](https://railway.app)
   - Sign up or log in
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository

3. **Railway will automatically**:
   - Detect the Dockerfile
   - Build the Docker image
   - Deploy the application
   - Provide a public URL

4. **That's it!** Your API will be available at the provided Railway URL.

### Option 2: Deploy with Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Deploy
railway up
```

## 📋 Configuration Details

### Port Configuration

The application automatically detects Railway's `PORT` environment variable and binds to `0.0.0.0:PORT`. No manual configuration needed!

### Default Command

The Dockerfile defaults to:
```bash
google-maps-scraper -web -data-folder /app/data
```

This starts the web server with API endpoints.

### Resource Requirements

**Minimum recommended:**
- **Memory**: 1GB+ (Playwright browsers need memory)
- **Storage**: 5GB+ recommended
- **CPU**: 1 vCPU minimum

**Note**: Railway's free tier may not have enough resources. Consider upgrading to a paid plan for production use.

## 🔧 Environment Variables (Optional)

You can set these in Railway dashboard → Variables:

- `DISABLE_TELEMETRY=1` - Disable anonymous usage tracking
- `PORT` - Automatically set by Railway (don't override)

## 📊 Data Persistence

By default, data is stored in `/app/data` which is **ephemeral** (lost on redeploy).

### To Persist Data:

1. **Add a Volume in Railway**:
   - Go to your project → Settings → Volumes
   - Click "Add Volume"
   - Mount it to `/app/data`

2. **Or use external storage**:
   - Use S3 for result storage
   - Use a database for job storage (PostgreSQL)

## 🌐 Using Your Deployed API

Once deployed, your API will be available at:
```
https://your-project-name.up.railway.app
```

### Test the API:

```bash
# Create a job
curl -X POST "https://your-project-name.up.railway.app/api/v1/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Job",
    "keywords": ["restaurants in New York"],
    "lang": "en",
    "depth": 1,
    "max_time": 600
  }'

# View API docs
open https://your-project-name.up.railway.app/api/docs
```

## 🐛 Troubleshooting

### Build Fails

- Check Railway build logs
- Ensure Dockerfile is in root directory
- Verify `railway.toml` is correct
- Check memory limits (may need to upgrade plan)

### Application Crashes

- Check Railway logs: `railway logs`
- Verify Playwright browsers are installed correctly
- Check memory usage (Playwright needs significant memory)

### Port Issues

- Railway automatically sets PORT - don't override it
- The app binds to `0.0.0.0:PORT` automatically

### Out of Memory

- Upgrade Railway plan
- Reduce concurrency in job requests
- Use fast_mode for lighter scraping

## 📝 Files Created for Railway

- `railway.toml` - Railway configuration
- `.railwayignore` - Files to exclude from deployment
- Updated `Dockerfile` - Default web mode command
- Updated `runner/runner.go` - PORT environment variable support

## ✅ Verification Checklist

Before deploying, ensure:

- [ ] Dockerfile exists in root
- [ ] railway.toml is present
- [ ] Code is pushed to GitHub (if using GitHub deploy)
- [ ] Railway account is set up
- [ ] Sufficient resources allocated (1GB+ RAM recommended)

## 🎉 You're Ready!

Just push to Railway and it should work! The configuration handles:
- ✅ Port binding
- ✅ Web server startup
- ✅ Data directory creation
- ✅ Playwright browser setup

If you encounter any issues, check the Railway logs or refer to the troubleshooting section above.

