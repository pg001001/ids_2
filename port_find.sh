#!/bin/bash

# Function to perform port scanning for a given IP
port_scan() {
    local ip=$1
    local date=$(date +'%Y-%m-%d')
    local base_dir="${domain}/$([ "$IGNORE_SPLIT" = "false" ] && echo "${date}/")"
    mkdir -p "${base_dir}"
    
    # Port scanning using naabu
    echo "Running naabu for IP ${ip}..."
    naabu -host "${ip}" -top-ports 100 -nmap-cli 'nmap -sV -oX nmap-output' | tee -a "${base_dir}/ports-${ip}.txt"
    mv nmap-output "${base_dir}/nmap-${ip}.xml"
    echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
}

# Check if domain and subdomain list file are provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1
base_dir="${domain}/$(date +'%Y-%m-%d')"
subdomain_file="${base_dir}/live_subdomains.txt"

# Check if the subdomain file exists
if [ ! -f "$subdomain_file" ]; then
    echo "Subdomain file ${subdomain_file} not found!"
    exit 1
fi

# Step 1: Resolve IP addresses for each subdomain in the file
echo "Resolving IP addresses for subdomains listed in ${subdomain_file}..."
ips=()
while IFS= read -r subdomain; do
    ip=$(dig +short "${subdomain}" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    if [ -n "$ip" ]; then
        ips+=("${ip}")
        echo "${subdomain} resolved to ${ip}"
    else
        echo "Failed to resolve IP for ${subdomain}"
    fi
done < "$subdomain_file"

# Remove duplicate IPs
unique_ips=$(echo "${ips[@]}" | tr ' ' '\n' | sort -u)

# Step 2: Perform port scanning for each unique IP
for ip in $unique_ips; do
    port_scan "$ip"
done

echo "Scanning completed for domain ${domain}."
