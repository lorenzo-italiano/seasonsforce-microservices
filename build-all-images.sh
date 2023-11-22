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
      echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Executing build-images.sh script in $dir...\033[0m"
      ./build-images.sh
      echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Script executed successfully.\033[0m"
    else
      echo -e "\033[31m======> \033[1;31;47m[Error]\033[0;31m No build-images.sh script found in $dir\033[0m"
    fi

    # Move back to the parent directory
    cd - || continue
  fi
done
