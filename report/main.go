package main

import (
	"bytes"
	"context"
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"cloud.google.com/go/logging"
	"github.com/google/uuid"
	_ "github.com/lib/pq"
)

type UsageData struct {
	Name        string `json:"metricName"`
	StartTime   string `json:"startTime"`
	EndTime     string `json:"endTime"`
	Value       int    `json:"metricValue"`
	OperationID string `json:"operationId"`
	ConsumerID  string `json:"consumerId"`
}

func main() {
	fmt.Println("Starting...")
	// SQL query to retrieve the number of total devices; including deleted devices in a day.

	//sqlQuery := "select count(*) as total_device from device;"
	sqlQuery := "select count(*)+(select count(*) from audit_log where action_type='DELETED' and entity_type='DEVICE' and action_status='SUCCESS' and to_timestamp(created_time/1000)::date = current_date) from device;"

	// Initialize variables to store metric name and value
	var metricName string

	//randomNumber := rand.Intn(100) + 1
	// Retrieving CONSUMER_ID from ENV VAR
	consumer_id := os.Getenv("AGENT_CONSUMER_ID")

	// Get the current date and time in UTC
	//currentTime := time.Now().UTC()
	currentTime := time.Now().UTC()
	var numDevices int

	if currentTime.Day() == 28 && currentTime.Hour() == 22 && currentTime.Minute() == 30 {
		numDevices, _ = executeSQLQueryWithRetry(sqlQuery)
	} else {
		numDevices = 0
	}

	if numDevices <= 10000 {
		metricName = "plan1_tier"
	} else {
		metricName = "custom"
		fmt.Println("Number of devices is greater than 10000. Please contact google_marketplace@vvdntech.in for custom pricing.")
	}

	// Display the selected metric name and the number of devices
	fmt.Printf("Number of Devices: %d\n", numDevices)
	fmt.Printf("Metric Name: %s\n", metricName)

	// Get the project ID
	projectID, err := getProjectID()
	if err != nil {
		log.Fatal(err)
	}

	startTime := time.Now().UTC().Add(-time.Hour).Format("2006-01-02T15:00:00Z")
	// Generate report.json with dynamic content
	reportContent := fmt.Sprintf("{\"name\": \"%s\", \"startTime\": \"%s\", \"endTime\": \"%s\", \"value\": { \"int64Value\": %d }}",
		metricName, startTime, time.Now().UTC().Format("2006-01-02T15:00:00Z"), numDevices)

	// Printing report.json
	fmt.Println("Printing contents of generated report.json file:")
	fmt.Println(reportContent)

	// Write reportContent to report.json file
	err = writeToFile("report.json", reportContent)
	if err != nil {
		log.Fatalf("Error writing to report.json: %v\n", err)
	}

	// Send a POST request using the HTTP client
	if err := sendHTTPPostRequestWithRetry("http://localhost:4567/report", "report.json"); err != nil {
		log.Fatalf("Request failed: %v\n", err)
	} else {
		fmt.Println("Request sent successfully.")
	}

	// Send Logging
	usageData := UsageData{}
	usageData.Name = metricName
	usageData.StartTime = startTime
	usageData.EndTime = time.Now().UTC().Format("2006-01-02T15:00:00Z")
	usageData.OperationID = uuid.New().String()
	usageData.ConsumerID = consumer_id
	usageData.Value = numDevices

	sendLogging(usageData, projectID)
}

func executeSQLQueryWithRetry(sqlQuery string) (int, error) {
	host := os.Getenv("PGHOST")
	port := os.Getenv("PGPORT")
	user := os.Getenv("PGUSER")
	password := os.Getenv("PGPASSWORD")
	dbname := os.Getenv("PGDATABASE")

	// Replace with your PostgreSQL database connection details
	connStr := fmt.Sprintf("host=%s port=%s dbname=%s user=%s password=%s sslmode=disable", host, port, dbname, user, password)

	var numDevices int
	var err error

	for attempt := 1; ; attempt++ {
		fmt.Printf("Attempting to execute SQL query\n")

		db, dbErr := sql.Open("postgres", connStr)
		if dbErr != nil {
			err = dbErr
			log.Printf("Error opening database connection: %v\n", err)
			time.Sleep(2 * time.Second) // Wait for a while before retrying
			continue
		}

		err = db.Ping()
		if err != nil {
			db.Close()
			log.Printf("Error pinging the database: %v\n", err)
			time.Sleep(2 * time.Second) // Wait for a while before retrying
			continue
		}

		// Execute the SQL query
		err = db.QueryRow(sqlQuery).Scan(&numDevices)
		db.Close()

		if err == nil {
			break // Query succeeded, exit the loop
		}

		log.Printf("Error executing SQL query: %v\n", err)
		time.Sleep(2 * time.Second) // Wait for a while before retrying
	}

	if err != nil {
		log.Fatalf("Error executing SQL query: %v\n", err)
	}

	return numDevices, nil
}

func writeToFile(filename, content string) error {
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.WriteString(content)
	if err != nil {
		return err
	}

	return nil
}

func sendHTTPPostRequestWithRetry(url, jsonFile string) error {
	// Read the content of the JSON file
	jsonData, err := ioutil.ReadFile(jsonFile)
	if err != nil {
		return err
	}

	var resp *http.Response
	var reqErr error

	for attempt := 1; ; attempt++ {
		fmt.Printf("Attempting to send HTTP POST request\n")

		resp, reqErr = http.Post(url, "application/json", bytes.NewBuffer(jsonData))
		if reqErr != nil {
			log.Printf("HTTP request failed: %v\n", reqErr)
			time.Sleep(2 * time.Second) // Wait for a while before retrying
			continue
		}

		if resp.StatusCode == http.StatusOK {
			resp.Body.Close()
			return nil // Request succeeded, exit the function
		}

		log.Printf("HTTP request failed with status code: %d\n", resp.StatusCode)
		resp.Body.Close()
		time.Sleep(2 * time.Second) // Wait for a while before retrying
	}
}

func getProjectID() (string, error) {
	// URL for the Google Cloud Metadata endpoint
	url := "http://metadata.google.internal/computeMetadata/v1/project/project-id"

	// Create a new HTTP request
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", fmt.Errorf("error sending request to get ProjectID: %v", err)
	}

	// Set the Metadata-Flavor header to "Google"
	req.Header.Set("Metadata-Flavor", "Google")

	// Create an HTTP client
	client := &http.Client{}

	// Send the request and get the response
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("error trying to get ProjectID: %v", err)
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading ProjectID: %v", err)
	}

	// Return the project_id as a string
	return string(body), nil
}

func sendLogging(ubbData UsageData, projectID string) {
	ctx := context.Background()

	// Creates a client.
	client, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create logging client: %v", err)
	}
	defer client.Close()

	// Sets the name of the log to write to.
	lg := client.Logger("ubb_testing")

	lg.Log(logging.Entry{Payload: ubbData})

	fmt.Println("Sending logs to Cloud Logging")
}
