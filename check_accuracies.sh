#!/bin/bash

if [[ "$#" != 1 ]] ; then
    echo "Usage:"
    echo "$0 <iteration>"
    exit 1
fi

iteration=$1

for bitmask in 01111111 10111111 11011111 11101111 11110111 11111011 11111101 11111110 ; do
    # Copy caffe log files to directory with results. This should have been done
    # by setting GLOG_log_dir in train.sh, but somehow the files were still sent
    # to /tmp, and will be flushed on restart if we don't copy them.
    ssh ec2imagenet-$bitmask "cp -f /tmp/caffe.* /home/achald/local/caffe/randomization_experiments/$bitmask/"

    # Search for the iteration we're interested in, get the accuracy.
    accuracy=$(ssh ec2imagenet-$bitmask \
        "grep -A2 'Iteration $iteration' /home/achald/local/caffe/randomization_experiments/$bitmask/caffe.INFO \
        | grep 'Test.*accuracy' \
        | sed -e 's/.* \(.*\)$/\1/'")

    echo "$bitmask - $accuracy"
done
