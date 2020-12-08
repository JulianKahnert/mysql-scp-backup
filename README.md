# MySQL Database Backups

This container can be used for backups hosted by [Hetzner Storage Box](https://www.hetzner.com/de/storage/storage-box).

```bash
# run container locally 
# content of the env-file can be found in the configuration section of this README
docker run --env-file ./env-file -it mysqlclient 

# open shell in this container
docker run -it worldiety/mysql-scp-backup:latest sh
```

## Configuration

Here is a list of all configuration options (e.g. environment variables) of this container.
This can be used as an `env-file`.

```bash
# Set Default Environment Variables
DB_HOST=localhost
DB_PORT=3306
DB_USER=backup-user
ENV DB_PASSWORD=TOP-SECRET
ENV DB_NAMES=database1,database2

# since several databases (e.g. dev, stage, prod) might be saved at the same destination, we must specify a unique name for each database service
SERVICE_NAME=my-db-service-prod

# writable location
TEMP_LOCATION=/tmp

# Number of backups to keep, default: 0, e.g. do not delete any backup
BACKUPS_TO_KEEP=5

SSH_STORAGE_URL=USER@USER.your-storagebox.de
SSH_BASE64_PRIVATE_KEY=TOP-SECRET
SSH_BASE64_PUBLIC_KEY=NOT-SO-SECRET
```

## Authentication

The public and private key that should be used for authentication can be created and uploaded with the `create-keys.sh` script.

It runs the following steps:

* create `tmp` folder for the keys
* create 4096Bit RSA keys
* uploads keys to Hetzner Storage Box via `sftp`
* outputs `SSH_BASE64_PRIVATE_KEY` and `SSH_BASE64_PUBLIC_KEY` environment variables that base64 encoded

```bash
./create-keys.sh 
```

## Build & Push manuelly

```bash
docker build -t worldiety/mysql-scp-backup:temp .
docker push worldiety/mysql-scp-backup:temp
```
