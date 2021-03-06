#!/bin/bash

if [[ "$#" != 1 ]] ; then
    echo "Usage:"
    echo "./${0} <bitmask>"
    exit 1
fi

bitmask=$1

pushd /data/imagenet

rm -rf ilsvrc12_train_lmdb
rm -rf ilsvrc12_val_lmdb
aws s3 cp s3://imagenet-randomization-results/lmdbs/ilsvrc12_train_lmdb/ ilsvrc12_train_lmdb --recursive
aws s3 cp s3://imagenet-randomization-results/lmdbs/ilsvrc12_val_lmdb/ ilsvrc12_val_lmdb --recursive

popd

pushd /home/achald
if [[ ! -d imagenet-randomization-caffe ]] ; then
    git clone https://github.com/achalddave/imagenet-randomization-caffe
else
    pushd imagenet-randomization-caffe
    git pull origin master
    popd
fi
popd

pushd /home/achald/local/caffe
ln -s /home/achald/imagenet-randomization-caffe/create_config_dir.py .
ln -s /home/achald/imagenet-randomization-caffe/train.sh .
echo 'Created links.'

echo 'Training.'
export PYTHONPATH="/home/achald/local/caffe/python:${PYTHONPATH}"
./train.sh $bitmask
popd
