package web

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/gosom/google-maps-scraper/gmaps"
)

type Service struct {
	repo       JobRepository
	dataFolder string
}

func NewService(repo JobRepository, dataFolder string) *Service {
	return &Service{
		repo:       repo,
		dataFolder: dataFolder,
	}
}

func (s *Service) Create(ctx context.Context, job *Job) error {
	return s.repo.Create(ctx, job)
}

func (s *Service) All(ctx context.Context) ([]Job, error) {
	return s.repo.Select(ctx, SelectParams{})
}

func (s *Service) Get(ctx context.Context, id string) (Job, error) {
	return s.repo.Get(ctx, id)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	if strings.Contains(id, "/") || strings.Contains(id, "\\") || strings.Contains(id, "..") {
		return fmt.Errorf("invalid file name")
	}

	datapath := filepath.Join(s.dataFolder, id+".csv")

	if _, err := os.Stat(datapath); err == nil {
		if err := os.Remove(datapath); err != nil {
			return err
		}
	} else if !os.IsNotExist(err) {
		return err
	}

	return s.repo.Delete(ctx, id)
}

func (s *Service) Update(ctx context.Context, job *Job) error {
	return s.repo.Update(ctx, job)
}

func (s *Service) SelectPending(ctx context.Context) ([]Job, error) {
	return s.repo.Select(ctx, SelectParams{Status: StatusPending, Limit: 1})
}

func (s *Service) GetCSV(_ context.Context, id string) (string, error) {
	if strings.Contains(id, "/") || strings.Contains(id, "\\") || strings.Contains(id, "..") {
		return "", fmt.Errorf("invalid file name")
	}

	datapath := filepath.Join(s.dataFolder, id+".csv")

	if _, err := os.Stat(datapath); os.IsNotExist(err) {
		return "", fmt.Errorf("csv file not found for job %s", id)
	}

	return datapath, nil
}

func (s *Service) GetResultsJSON(_ context.Context, id string) ([]gmaps.Entry, error) {
	if strings.Contains(id, "/") || strings.Contains(id, "\\") || strings.Contains(id, "..") {
		return nil, fmt.Errorf("invalid file name")
	}

	datapath := filepath.Join(s.dataFolder, id+".csv")

	if _, err := os.Stat(datapath); os.IsNotExist(err) {
		return nil, fmt.Errorf("csv file not found for job %s", id)
	}

	file, err := os.Open(datapath)
	if err != nil {
		return nil, fmt.Errorf("failed to open csv file: %w", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("failed to read csv: %w", err)
	}

	if len(records) == 0 {
		return []gmaps.Entry{}, nil
	}

	// Skip header row
	entries := make([]gmaps.Entry, 0, len(records)-1)
	headers := records[0]

	for i := 1; i < len(records); i++ {
		entry := gmaps.Entry{}
		row := records[i]

		// Map CSV columns to Entry fields
		for j, header := range headers {
			if j >= len(row) {
				continue
			}

			value := row[j]
			switch header {
			case "input_id":
				entry.ID = value
			case "link":
				entry.Link = value
			case "title":
				entry.Title = value
			case "category":
				entry.Category = value
			case "address":
				entry.Address = value
			case "open_hours":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.OpenHours)
				}
			case "popular_times":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.PopularTimes)
				}
			case "website":
				entry.WebSite = value
			case "phone":
				entry.Phone = value
			case "plus_code":
				entry.PlusCode = value
			case "review_count":
				if value != "" {
					entry.ReviewCount, _ = strconv.Atoi(value)
				}
			case "review_rating":
				if value != "" {
					entry.ReviewRating, _ = strconv.ParseFloat(value, 64)
				}
			case "reviews_per_rating":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.ReviewsPerRating)
				}
			case "latitude":
				if value != "" {
					entry.Latitude, _ = strconv.ParseFloat(value, 64)
				}
			case "longitude":
				if value != "" {
					entry.Longtitude, _ = strconv.ParseFloat(value, 64)
				}
			case "cid":
				entry.Cid = value
			case "status":
				entry.Status = value
			case "descriptions":
				entry.Description = value
			case "reviews_link":
				entry.ReviewsLink = value
			case "thumbnail":
				entry.Thumbnail = value
			case "timezone":
				entry.Timezone = value
			case "price_range":
				entry.PriceRange = value
			case "data_id":
				entry.DataID = value
			case "images":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.Images)
				}
			case "reservations":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.Reservations)
				}
			case "order_online":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.OrderOnline)
				}
			case "menu":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.Menu)
				}
			case "owner":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.Owner)
				}
			case "complete_address":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.CompleteAddress)
				}
			case "about":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.About)
				}
			case "user_reviews":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.UserReviews)
				}
			case "user_reviews_extended":
				if value != "" {
					_ = json.Unmarshal([]byte(value), &entry.UserReviewsExtended)
				}
			case "emails":
				if value != "" {
					entry.Emails = strings.Split(value, ",")
				}
			}
		}

		entries = append(entries, entry)
	}

	return entries, nil
}
