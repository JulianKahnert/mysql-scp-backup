# ================================
# Build image
# ================================
FROM swift:5.3-focal as build

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations and test discovery
RUN swift build --enable-test-discovery -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/PerformBackup" ./

# ================================
# Run image
# ================================
FROM swift:5.3-focal-slim

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y \
    && apt-get install -y ssh mysql-client \
    && rm -r /var/lib/apt/lists/*

# Copy built executable and any staged resources from builder
COPY --from=build /staging /usr/bin/
RUN mkdir -p /root/.ssh/ && chmod -R 600 /root/.ssh/

# Set Default Environment Variables
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_USER=CHANGEME
ENV DB_PASSWORD=CHANGEME
ENV DB_NAMES='database-name-1,database-name-2'

# since several databases (e.g. dev, stage, prod) might be saved at the same destination, we must specify a unique name for each database service
ENV SERVICE_NAME=''

# writable location - no trailing backslash!
ENV TEMP_LOCATION=/tmp

# Number of backups to keep, default: 0, e.g. do not delete any backup
ENV BACKUPS_TO_KEEP=0

ENV SSH_STORAGE_URL=localhost
ENV SSH_BASE64_PRIVATE_KEY=U0VDUkVUCg==
ENV SSH_BASE64_PUBLIC_KEY=U0VDUkVUCg==

# # Copy backup script and execute
# COPY perform-backup.sh /
# RUN chmod +x /perform-backup.sh
CMD PerformBackup
