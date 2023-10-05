#!/bin/bash

num_devices=800

# SQL query to retrieve the number of total devices; including deleted devices in a day.
# SQL_QUERY="select count(*)+(select count(*) from audit_log where action_type='DELETED' and entity_type='DEVICE' and action_status='SUCCESS' and to_timestamp(created_time/1000)::date = current_date) from device;"
SQL_QUERY="select count(*) as total_device from device;" 


# Execute the SQL query using psql and capture the result in num_devices
# num_devices=$(psql -h $PGHOST -p $PGPORT -d $PGDATABASE  -U $PGUSER -c "$SQL_QUERY" -t | tr -d '[:space:]')


# Check for errors in the psql command
if [ $? -ne 0 ]; then
    echo "Error executing SQL query."
    exit 1
fi

# Initialize variables to store metric name and value
metric_name=""
metric_value=""

# Determine the metric name and slab based on the number of devices
# if [ $num_devices -le 500 ]; then
#     metric_name="developer"
# elif [ $num_devices -gt 500 ] && [ $num_devices -le 5000 ]; then
#     metric_name="basic"
# elif [ $num_devices -gt 5000 ] && [ $num_devices -le 10000 ]; then
#     metric_name="professional"
# elif [ $num_devices -gt 10000 ] && [ $num_devices -le 25000 ]; then
#     metric_name="advanced"
# else
#     echo "Number of devices is greater than 25000. No metric will be sent."
#     exit 1
# fi

if [ $num_devices -le 10000 ]; then
    metric_name="standard"
elif [ $num_devices -gt 10000 ]; then
    metric_name="custom"
    echo "Number of devices is greater than 10000. Please contact  google_marketplace@vvdntech.in for custom pricing."
fi

# Display the selected metric name and the number of devices
echo -e "Number of Devices: $num_devices \n"
echo -e "Metric Name: $metric_name \n"

# Generate report.json with dynamic content
report_content="{\"name\": \"$metric_name\", \"startTime\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"endTime\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"value\": { \"int64Value\": 1 }}"
echo "$report_content" | jq '.' > report.json

#Printing report.json
echo -e "Printing contents of generated report.json file:"
cat report.json

# Send a curl POST request
curl -X POST -d "@report.json" 'http://localhost:4567/report'

echo "Request Sent"