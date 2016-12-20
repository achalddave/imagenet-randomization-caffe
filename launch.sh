#!/bin/bash
# Usage:
#   ./launch.sh <bitmask>

set -e

if [[ "$#" != 1 ]] ; then
    echo "Usage:"
    echo "./launch.sh <bitmask>"
    exit 1
fi

bitmask=$1

echo "Launching training with bitmask ${bitmask}"

scp launch_helper.sh ec2imagenet-${bitmask}:/tmp/
ssh -t ec2imagenet-${bitmask} "tmux new-session -s ${bitmask} 'bash /tmp/launch_helper.sh'"
