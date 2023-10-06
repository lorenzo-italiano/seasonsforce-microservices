#!/bin/bash

# Loop through all directories starting with "seasonsforce-"
for dir in seasonsforce-*; do
  # Check if it exists and is a directory
  if [ -d "$dir" ]; then
    # Move into the directory
    cd "$dir" || continue

    # Check if "build-images.sh" script exists
    if [ -f "build-images.sh" ]; then
      # Execute the script
      echo "Executing build-images.sh script in $dir..."
      ./build-images.sh
      echo "Script executed successfully."
    else
      echo "No build-images.sh script found in $dir"
    fi

    # Move back to the parent directory
    cd - || continue
  fi
done
