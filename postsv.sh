#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: bash $0 <total_requests>"
  exit 1
fi

# Define the URL
url="https://be.qabilah.com/Posts/Th459RPBsZc"

# Number of times to repeat the process
total_requests=$1

# Number of requests per batch
batch_size=100

# Loop through and make requests
for ((i = 0; i < total_requests; i += batch_size)); do
  views_count_batch=()
  
  for ((j = 0; j < batch_size; j++)); do
    (
      # Make the request
      response=$(curl -s "$url")
      
      # Extract viewsCount using grep and sed
      views_count=$(echo "$response" | grep -o '"viewsCount":[0-9]*' | sed 's/"viewsCount"://')
      
      # Append the result to a temporary file (each in parallel)
      echo "$views_count" >> /tmp/views_batch_$i.txt
    ) &
  done

  # Wait for all parallel requests to complete
  wait
  
  # Read all viewsCount values from the temporary file
  views_count_batch=$(cat /tmp/views_batch_$i.txt)
  
  # Print the results of the current batch
  echo "Batch $((i/batch_size + 1)) Results: $views_count_batch"
  
  # Remove the temporary file
  rm /tmp/views_batch_$i.txt
  
  # Sleep for 2 seconds before the next batch
  sleep 2
done
