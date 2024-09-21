#!/bin/bash

# Check if domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Function to scan for JavaScript files, download them, and search for sensitive information
sensitive_scan() {
    local domain=$1
    local base_dir="${domain}"
    mkdir -p "${base_dir}"
    mkdir -p "${base_dir}/exposure/"

    dirsearch -u "${domain}" -r -w '/root/main/wordlist/cgi-bin.txt' -o "${base_dir}/exposure/cgi-bin.txt"

}

# Run the JS scan function with the provided domain
sensitive_scan "$1"
