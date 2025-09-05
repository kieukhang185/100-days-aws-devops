#!/bin/bash
# Auto mode for the dotfiles installation script
set -ex

# create menu for auto create days folder and README.md file
echo "Select an option:"
echo "1) Create days folder and README.md file"
echo "2) Skip"
read -p "Enter your choice [1-2]: " choice
case $choice in
    1)
        WORK_DIR=$(find $HOME -type d -name "100-days-aws-devops" -print -quit)
        cd ${WORK_DIR}
        echo "Current working directory: $WORK_DIR"
        read -p "Enter the number of days to create folders for: " num_days
        if ! [[ "$num_days" =~ ^[0-9]+$ ]]; then
            echo "Error: Please enter a valid number."
            exit 1
        fi
        days_file="100days.txt"
        if [[ ! -f "$days_file" ]]; then
            echo "Error: $days_file not found!"
            exit 1
        fi
        day_folder=$(sed -n "${num_days}p" "$days_file" | tr -d '\r\n')
        day_folder=$(echo "$day_folder" | tr '[:upper:]' '[:lower:]') # convert to lowercase
        day_folder=$(echo "$day_folder" | sed 's/ /-/g') # replace spaces with -
        # replace all spaces, commas, and special characters with -
        day_folder=$(echo "$day_folder" | tr ' ,!@#$%^&*()—+=[]{};:'"'"'\"<>?/|' '-' | tr -s '-')
        echo "Creating folder for day $i: $day_folder"
        mkdir -p "$day_folder"
        echo "# Day $i" > "$day_folder/README.md"
        echo "Created folder '$day_folder' with README.md"

        ;;
    2)
        echo "Skipping folder and README.md creation."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
