#!/bin/ash

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
echo -e "${SKY_BLUE}Cooldown between playlists${NC}: ${COOLDOWN_SECONDS} seconds"
echo -e "${ORANGE}SpotiFLAC flags${NC}: ${SPOTIFLAC_FLAGS}"

# Function to process each playlist URL
process_playlist() {
    playlist_url="$1"
    current="$2"
    total="$3"

    # Trim whitespace from URL
    playlist_url=$(echo "$playlist_url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ -n "$playlist_url" ]; then
        echo -e "${GREEN}Processing playlist${NC} $current/$total: $playlist_url"

        # Execute SpotiFLAC with the playlist URL and flags
        python SpotiFLAC.py "$playlist_url" $SPOTIFLAC_FLAGS

        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo -e "${YELLOW}WARNING: SpotiFLAC exited with code${NC} $exit_code ${YELLOW}for playlist${NC}: $playlist_url"
        else
            echo -e "${GREEN}Successfully processed playlist${NC}: $playlist_url"
        fi

        return $exit_code
    fi
    return 0
}

# POSIX-compliant way to split semicolon-separated URLs
current=1
total_playlists=0

# First pass: count total playlists
temp_urls="$PLAYLIST_URLS"
while [ -n "$temp_urls" ]; do
    case "$temp_urls" in
        *\;*)
            temp_urls="${temp_urls#*;}"
            total_playlists=$((total_playlists + 1))
            ;;
        *)
            total_playlists=$((total_playlists + 1))
            break
            ;;
    esac
done

# Second pass: process each playlist
remaining_urls="$PLAYLIST_URLS"
while [ -n "$remaining_urls" ]; do
    case "$remaining_urls" in
        *\;*)
            # Extract first URL before semicolon
            playlist_url="${remaining_urls%%;*}"
            # Remove processed URL and semicolon from remaining
            remaining_urls="${remaining_urls#*;}"
            ;;
        *)
            # Last URL (no semicolon)
            playlist_url="$remaining_urls"
            remaining_urls=""
            ;;
    esac

    # Process this playlist
    process_playlist "$playlist_url" "$current" "$total_playlists"

    # Add cooldown between playlists (except for the last one)
    if [ $current -lt $total_playlists ]; then
        echo -e "${SKY_BLUE}Waiting ${COOLDOWN_SECONDS} seconds before next playlist...${NC}"
        sleep $COOLDOWN_SECONDS
    fi

    current=$((current + 1))
done

echo -e "${GREEN}All playlists processed!${NC}"
