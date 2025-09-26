#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
SKY_BLUE='\033[38;5;27m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color (resets to default)

# Check if required environment variables are set
if [ -z "$PLAYLIST_URLS" ]; then
    echo -e "${RED}ERROR: PLAYLIST_URLS environment variable is required${NC}"
    exit 1
fi

# Set defaults
COOLDOWN_SECONDS=${COOLDOWN_SECONDS:-30}
SPOTIFLAC_FLAGS=${SPOTIFLAC_FLAGS:-""}

# echo -e ${SKY_BLUE}Starting SpotiFLAC downloader...${NC}"
echo -e "${SKY_BLUE}Cooldown between playlists${NC}: ${COOLDOWN_SECONDS} sec"
echo -e "${ORANGE}SpotiFLAC flags${NC}: ${SPOTIFLAC_FLAGS}"

# Split playlist URLs by semicolon and process each one
IFS=';' read -ra URLS <<< "$PLAYLIST_URLS"

total_playlists=${#URLS[@]}
current=1

for playlist_url in "${URLS[@]}"; do
    # Trim whitespace from URL
    playlist_url=$(echo "$playlist_url" | xargs)

    if [ -n "$playlist_url" ]; then
        echo -e "${GREEN}Processing playlist${NC} $current/$total_playlists: $playlist_url"

        # Execute SpotiFLAC with the playlist URL and flags
        python SpotiFLAC.py "$playlist_url" $SPOTIFLAC_FLAGS

        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo -e "${YELLOW}WARNING: SpotiFLAC exited with code${NC} $exit_code ${YELLOW}for playlist${NC}: $playlist_url"
        else
            echo -e "${GREEN}Successfully processed playlist${NC}: $playlist_url"
        fi

        # Add cooldown between playlists (except for the last one)
        if [ $current -lt $total_playlists ]; then
            echo -e "${SKY_BLUE}Waiting ${COOLDOWN_SECONDS} seconds before next playlist...${NC}"
            sleep $COOLDOWN_SECONDS
        fi

        current=$((current + 1))
    fi
done

echo -e "${GREEN}All playlists processed!${NC}"
