#!/bin/bash

if [[ "$#" != 1 ]] ; then
    echo "Usage:"
    echo "$0 <iteration>"
    exit 1
fi

iteration=$1

for bitmask in 01111111 10111111 11011111 11101111 11110111 11111011 11111101 11111110 ; do
    ssh ec2imagenet-$bitmask "cp -f /tmp/caffe.* /home/achald/local/caffe/randomization_experiments/$bitmask/"
    accuracy=$(ssh ec2imagenet-$bitmask "grep -A2 'Iteration $iteration' /home/achald/local/caffe/randomization_experiments/$bitmask/caffe.INFO | grep 'Test.*accuracy' | sed -e 's/.* \(.*\)$/\1/'")
    echo "$bitmask - $accuracy"
done
