#!/bin/bash

echo -e "\033[0;32mUploading blog static site...\033[0m"
git add .
git commit -m "rebuild blog $(date +'%Y-%m-%d')"
git push origin main
