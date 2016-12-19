#!/bin/bash

# Usage:
#    ./train.sh bitmask [output_dir]
#
# After this script is run, output_dir will have the following files:
#   - solver.prototxt
#   - train_val.prototxt
#   - deploy.prototxt
#   - models/
#   - log/
#
# Finally, output_dir will be copied to S3.


if [[ "$#" != 1 && "$#" != 2 ]] ; then
    echo "Usage:"
    echo "$0 <bitmask> [output_dir]"
    exit 1
fi

bitmask=$1
if [[ "$#" == 2 ]] ; then
    output_dir="$2"
else
    output_dir=randomization_experiments/$bitmask
fi
GLOG_log_dir=$output_dir/log/

mkdir -p $output_dir

python create_config_dir.py \
    --bitmask $bitmask \
    --output $output_dir \
    --solver models/bvlc_alexnet/solver.prototxt \
    --trainval models/bvlc_alexnet/train_val.prototxt \
    --deploy models/bvlc_alexnet/deploy.prototxt \
    --snapshot_prefix $output_dir/models/model || exit 1
mkdir -p $output_dir/models

solver_path=$output_dir/solver.prototxt
./build/tools/caffe train --solver=$solver_path

# Copy output_dir to s3
aws s3 cp $output_dir s3://imagenet-randomization-results/$bitmask \
    --recursive
