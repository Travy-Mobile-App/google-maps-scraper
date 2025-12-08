#!/usr/bin/env python3
"""
Example Python client for Google Maps Scraper API
"""

import requests
import time
import sys
from typing import Optional, Dict, Any


class GoogleMapsScraperClient:
    """Client for interacting with Google Maps Scraper API"""
    
    def __init__(self, base_url: str = "http://localhost:8080"):
        self.base_url = base_url.rstrip('/')
        self.api_base = f"{self.base_url}/api/v1"
    
    def create_job(
        self,
        name: str,
        keywords: list[str],
        lang: str = "en",
        zoom: int = 15,
        lat: Optional[str] = None,
        lon: Optional[str] = None,
        fast_mode: bool = False,
        radius: int = 10000,
        depth: int = 1,
        email: bool = False,
        max_time: int = 3600,
        proxies: Optional[list[str]] = None
    ) -> str:
        """
        Create a new scraping job
        
        Returns:
            Job ID (UUID string)
        """
        payload = {
            "name": name,
            "keywords": keywords,
            "lang": lang,
            "zoom": zoom,
            "fast_mode": fast_mode,
            "radius": radius,
            "depth": depth,
            "email": email,
            "max_time": max_time,
            "proxies": proxies or []
        }
        
        if lat and lon:
            payload["lat"] = lat
            payload["lon"] = lon
        
        response = requests.post(
            f"{self.api_base}/jobs",
            json=payload
        )
        response.raise_for_status()
        
        return response.json()["id"]
    
    def get_job(self, job_id: str) -> Dict[str, Any]:
        """Get job details"""
        response = requests.get(f"{self.api_base}/jobs/{job_id}")
        response.raise_for_status()
        return response.json()
    
    def list_jobs(self) -> list[Dict[str, Any]]:
        """List all jobs"""
        response = requests.get(f"{self.api_base}/jobs")
        response.raise_for_status()
        return response.json()
    
    def wait_for_completion(
        self,
        job_id: str,
        poll_interval: int = 5,
        timeout: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Wait for job to complete
        
        Args:
            job_id: Job UUID
            poll_interval: Seconds between status checks
            timeout: Maximum seconds to wait (None for no timeout)
        
        Returns:
            Final job status dictionary
        """
        start_time = time.time()
        
        while True:
            job = self.get_job(job_id)
            status = job["status"]
            
            print(f"Job {job_id[:8]}... status: {status}")
            
            if status in ["ok", "failed"]:
                return job
            
            if timeout and (time.time() - start_time) > timeout:
                raise TimeoutError(f"Job did not complete within {timeout} seconds")
            
            time.sleep(poll_interval)
    
    def download_results(self, job_id: str, output_file: str) -> None:
        """Download job results as CSV"""
        response = requests.get(
            f"{self.api_base}/jobs/{job_id}/download",
            stream=True
        )
        response.raise_for_status()
        
        with open(output_file, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
    
    def delete_job(self, job_id: str) -> None:
        """Delete a job"""
        response = requests.delete(f"{self.api_base}/jobs/{job_id}")
        response.raise_for_status()


def main():
    """Example usage"""
    client = GoogleMapsScraperClient()
    
    print("Creating scraping job...")
    job_id = client.create_job(
        name="Restaurants in NYC",
        keywords=["restaurants in New York", "pizza in Manhattan"],
        lang="en",
        zoom=15,
        lat="40.7128",
        lon="-74.0060",
        depth=1,
        max_time=1800
    )
    
    print(f"Job created: {job_id}")
    print("Waiting for completion...")
    
    try:
        final_job = client.wait_for_completion(job_id, timeout=300)
        
        if final_job["status"] == "ok":
            output_file = f"results-{job_id}.csv"
            print(f"Downloading results to {output_file}...")
            client.download_results(job_id, output_file)
            print("✅ Download complete!")
        else:
            print(f"❌ Job failed with status: {final_job['status']}")
            sys.exit(1)
    
    except TimeoutError as e:
        print(f"❌ {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

