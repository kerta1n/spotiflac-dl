FROM python:3-alpine

# Install system dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Clone the repository at build time
RUN git clone --depth 1 https://github.com/jelte1/SpotiFLAC-CLI.git . \
    && pip install --no-cache-dir requests beautifulsoup4 lxml mutagen tqdm pyotp

# Copy entrypoint script
COPY ./entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh  
# && sleep 5 && ls -la entrypoint.sh


CMD ["ash", "entrypoint.sh"]
# Set entrypoint
#ENTRYPOINT ash entrypoint.sh
