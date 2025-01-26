#!/bin/bash

NODENAME=follower-1
NODEIP=192.168.68.114

RETRIES=10
WAIT_TIME=10
TIMEOUT=30

kubectl drain $NODENAME --ignore-daemonsets --delete-emptydir-data

DRAINSUCCESS=$?
if [ $DRAINSUCCESS -ne 0 ]; then
    echo "Failed to drain node"
    exit 1
fi

ssh ubuntu@$NODEIP 'sudo apt update -y && sudo apt upgrade -y && sudo reboot'

sleep 90

# Retry loop
attempt=0
while (( attempt < RETRIES )); do
    echo "Attempt $((attempt + 1)) of $RETRIES to check SSH access..."

    # Check SSH access
    if ssh -q -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no "ubuntu@$NODEIP" exit; then
        echo "SSH access to $NODE is successful. uncordoning node after 20s..."
        sleep 20
        kubectl uncordon $NODENAME
        exit 0
    else
        echo "SSH access to $NODE failed. Retrying in $WAIT_TIME seconds..."
        sleep $WAIT_TIME
    fi

    attempt=$((attempt + 1))
done

# If we reach here, all retries failed
echo "SSH access to $NODE failed after $RETRIES attempts. Exiting..."
exit 1
