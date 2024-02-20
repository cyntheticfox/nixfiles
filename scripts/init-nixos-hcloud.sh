#!/bin/env bash

# PARAMETERS
SERVER_IMAGE='debian-12'
SERVER_TYPE='cpx11'
LOCATION='ash'
SSH_KEY_NAME='hcloud-init-ed25519_id'
SERVER_NAME='test-init'
NIXOS_INFECT_URL='https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect'
NIX_CHANNEL='nixos-23.11'
INSTALL_LOG_FILE_PATH='/tmp/infect.log'
FIREWALL_NAME='only-ssh-in'

# STATE INFO
GITROOT=git parse-rev --top-level
TEMP_DIR=mktemp
FIREWALL_RULES_PATH="$TEMP_DIR/hcloud-firewall--$FIREWALL_NAME.json"
CLOUD_CONFIG_PATH="$TEMP_DIR/hcloud-server-cloudinit.yml"
SSH_KEY_PATH="$GITROOT/out/$SSH_KEY_NAME"
SSH_KEY_PUB=''

if [[ -z $HCLOUD_TOKEN && -z $HCLOUD_CONTEXT ]]; then
    echo 'No credentials defined for Hetzner. Exiting...'
    rm -rf "$TEMP_DIR"

    exit 1
fi

function init_cloud_config() {
    tee "$CLOUD_CONFIG_PATH" <<EOF
runcmd:
  - "curl '$NIXOS_INFECT_URL' | PROVIDER=hetznercloud NIX_CHANNEL='$NIX_CHANNEL' bash 2>&1 | tee '$INSTALL_LOG_FILE_PATH'"
EOF
}

function init_cloud_firewall() {
    tee "$FIREWALL_RULES_PATH" <<'EOF'
[
  {
    "description": "Allow in SSH port",
    "direction": "in",
    "port": 22,
    "protocol": "tcp"
  }
]
EOF
}

function init_ssh_key() {
    if [[ -f $SSH_KEY_PATH ]]; then
        echo "\`$SSH_KEY_PATH\` exists. Exiting..."
        rm -rf "$TEMP_DIR"

        exit 2
    fi

    mkdir "$GITROOT/out"
    ssh-keygen -t 'ed25519' -f "$SSH_KEY_PATH" -N ''
    SSH_KEY_PUB=$(cat "$SSH_KEY_PATH.pub")
}

# Actual script
init_cloud_config
init_cloud_firewall
init_ssh_key

hcloud ssh-key create \
    --name "$SSH_KEY_NAME" \
    --public-key "$SSH_KEY_PUB"

hcloud firewall create \
    --name "$FIREWALL_NAME" \
    --rules "$FIREWALL_RULES_PATH"

hcloud server create \
    --image "$SERVER_IMAGE" \
    --type "$SERVER_TYPE" \
    --location "$LOCATION" \
    --name "$SERVER_NAME" \
    --start-after-create 'true' \
    --without-ipv4 'true' \
    --ssh-key "$SSH_KEY_NAME" \
    --firewall "$FIREWALL_NAME" \
    --user-data-from-file "$CLOUD_CONFIG_PATH"

hcloud server create-image \
    --description "$(date --iso-8601=seconds)--$NIX_CHANNEL" \
    --type 'snapshot'

# Cleanup
hcloud server delete "$SERVER_NAME"

rm -rf "$TEMP_DIR"
