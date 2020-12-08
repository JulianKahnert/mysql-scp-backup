#!/bin/bash

KEY_PATH="$(pwd)/tmp"

mkdir "${KEY_PATH}" 2> /dev/null
rm "${KEY_PATH}"/id_rsa 2> /dev/null
rm "${KEY_PATH}"/id_rsa.pub 2> /dev/null

ssh-keygen -t rsa -b 4096 -N "" -f "${KEY_PATH}"/id_rsa

# upload pub ssh key to Hetzner Storage Box
printf "Uploading public SSH key:\n"

# convert to RFC public key: https://docs.hetzner.com/de/robot/storage-box/backup-space-ssh-keys/
ssh-keygen -e -f "${KEY_PATH}"/id_rsa.pub | grep -v "Comment:" >  storagebox_authorized_keys

# upload key
echo -e "mkdir .ssh \n chmod 700 .ssh \n put storagebox_authorized_keys .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp "${SSH_STORAGE_URL}"
rm storagebox_authorized_keys

# show environment variables
printf "\n\nENVIRONMENT VARIABLES\n\n"

printf "SSH_BASE64_PRIVATE_KEY="
base64 "${KEY_PATH}"/id_rsa

printf "\n\n"

printf "SSH_BASE64_PUBLIC_KEY="
base64 "${KEY_PATH}"/id_rsa.pub

