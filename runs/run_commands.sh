#!/bin/bash

# Check if the input file with commands is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <commands_file>"
  exit 1
fi

# Check if the input file exists
if [ ! -f "$1" ]; then
  echo "File not found: $1"
  exit 1
fi

# Define the output directory
output_dir="/home/god/Documents/Masters/runs"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Initialize the run counter
run_number=1

# Loop through each command in the input file
while IFS= read -r command; do
  # Prepend the binary path to the command
  full_command="$command"

  # Create a temporary file to capture the command output
  output_file="$output_dir/run_$run_number.txt"

  # Execute the command with a timeout of 5 minutes (300 seconds)
  timeout 300 bash -c "$full_command" 2>&1 | tee "$output_file"

  # Check the exit status of the command
  status=$?
  if [ $status -eq 124 ]; then
    echo "Command timed out and was killed: $command" | tee -a "$output_file"
  elif [ $status -ne 0 ]; then
    echo "Execution error: $command" | tee -a "$output_file"
  fi

  # Increment the run counter
  run_number=$((run_number + 1))

done < "$1"
