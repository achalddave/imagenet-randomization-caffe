#!/bin/bash
# Usage:
#   ./launch.sh <bitmask>

set -e

if [[ "$#" != 1 ]] ; then
    echo "Usage:"
    echo "./${0} <bitmask>"
    exit 1
fi

bitmask=$1

echo "Launching training with bitmask ${bitmask}"

ssh ec2imagenet-${bitmask} "rm -f /tmp/launch_helper.sh"
scp launch_helper.sh ec2imagenet-${bitmask}:/tmp/launch_helper.sh
ssh -t ec2imagenet-${bitmask} "tmux new-session -s ${bitmask} 'bash /tmp/launch_helper.sh ${bitmask} ; bash -i'"
