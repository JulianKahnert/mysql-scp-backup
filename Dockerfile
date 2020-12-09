# ================================
# Build image
# ================================
FROM swift:5.3-focal as build
MAINTAINER Julian Kahnert <julian.kahnert@worldiety.de>

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

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && \
    apt-get install -y ssh

# Latest MySQL Version
RUN apt-get -y install mysql-client

# # MySQL Version 5.7
# # we need to match so mysql version of the server (5.7) to avoid mysqldump problems:
# # https://webdevstudios.com/2020/11/19/mysql-database-export-errors-and-solutions/
# RUN echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
# RUN apt-get -q update && apt-get install -y mysql-client-5.7

RUN rm -r /var/lib/apt/lists/*

# Copy built executable and any staged resources from builder
COPY --from=build /staging /usr/bin/
RUN mkdir -p /root/.ssh/ && chmod -R 600 /root/.ssh/

# Set Default Environment Variables
ENV DB_HOST=''
ENV DB_PORT=''
ENV DB_USER=''
ENV DB_PASSWORD=''
ENV DB_NAMES=''

# since several databases (e.g. dev, stage, prod) might be saved at the same destination, we must specify a unique name for each database service
ENV SERVICE_NAME=''

# writable location 
ENV TEMP_LOCATION=''

# Number of backups to keep, default: 0, e.g. do not delete any backup
ENV BACKUPS_TO_KEEP=''

ENV SSH_STORAGE_URL=''
ENV SSH_BASE64_PRIVATE_KEY=''
ENV SSH_BASE64_PUBLIC_KEY=''

CMD PerformBackup
