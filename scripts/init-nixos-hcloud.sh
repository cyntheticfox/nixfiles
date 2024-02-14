#!/bin/env bash

SERVER_IMAGE='debian-12'
SERVER_TYPE='cpx11'
LOCATION='ash'
SSH_KEY_NAME=''
SERVER_NAME=''
read -r -d '' CLOUD_CONFIG <<EOF
runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-23.11 bash 2>&1 | tee /tmp/infect.log
EOF

SSH_KEY_PATH="./$SSH_KEY_NAME"

if [[ -f $SSH_KEY_PATH ]]; then
    echo "$SSH_KEY_PATH exists."
    exit 1
fi

ssh-keygen -t 'ed25519' -f "$SSH_KEY_PATH" -N ''

SSH_KEY_PUB=$(cat "$SSH_KEY_PATH.pub")

hcloud ssh-key create \
    --name "$SSH_KEY_NAME" \
    --public-key "$SSH_KEY_PUB"

# Create server
hcloud server create \
    --image "$SERVER_IMAGE" \
    --type "$SERVER_TYPE" \
    --location "$LOCATION" \
    --name "$SERVER_NAME" \
    --start-after-create 'true' \
    --without-ipv4 'true' \
    --ssh-key "$SSH_KEY_NAME" \
    --user_data "$CLOUD_CONFIG"

# Create snapshot

# Stop server
hcloud server delete "$SERVER_NAME"
