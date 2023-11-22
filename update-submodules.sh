#!/bin/bash

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Initializing submodules...\033[0m"
git submodule init

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Updating submodules...\033[0m"
git submodule update --recursive --remote

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Submodules updated successfully.\033[0m"

echo -e "\033[34m======> \033[1;34;47m[Info]\033[0;34m Committing changes to the parent repository...\033[0m"
git add .
git commit -m "chore(submodules): Updating submodules."
git push
