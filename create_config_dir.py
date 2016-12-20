# Creates a model configuration given a bitmask of layers to train.
#
# Usage:
#     python create_config_dir.py \
#         --bitmask 11111111 \
#         --output_dir /path/to/output_dir \
#         --solver models/bvlc_alexnet/solver.prototxt \
#         --trainval models/bvlc_alexnet/train_val.prototxt \
#         --deploy models/bvlc_alexnet/deploy.prototxt \
#         --snapshot_prefix $output_dir/models/model
#
# output_dir will contain the following files;
#   - solver.prototxt
#   - deploy.prototxt
#   - train_val.prototxt

import argparse
import errno
import os
from shutil import copyfile

# Necessary to run Caffe in a headless manner, of course.
# https://github.com/BVLC/caffe/issues/861#issuecomment-70124809
import matplotlib
matplotlib.use('Agg')

from caffe.proto.caffe_pb2 import SolverParameter, NetParameter
from google.protobuf import text_format

LAYERS = ["conv1", "conv2", "conv3", "conv4", "conv5", "fc6", "fc7", "fc8"]


def mkdir_p(path):
    # http://stackoverflow.com/a/600612/1291812
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


def parse_prototxt(protobuf_object, file_path):
    with open(file_path) as f:
        contents = f.read()
    text_format.Merge(contents, protobuf_object)


def write_prototxt(protobuf_object, file_path):
    with open(file_path, 'w') as f:
        f.write(text_format.MessageToString(protobuf_object))

def main():
    # Use first line of file docstring as description if a file docstring exists.
    parser = argparse.ArgumentParser(
        description=__doc__.split('\n')[0] if __doc__ else '',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--bitmask', type=str, required=True)
    parser.add_argument('--output', type=str, required=True)
    parser.add_argument(
        '--snapshot_prefix',
        default='{output}/models/alexnet_{bitmask}')
    parser.add_argument(
        '--solver',
        default='models/bvlc_alexnet/solver.prototxt')
    parser.add_argument(
        '--trainval',
        default='models/bvlc_alexnet/train_val.prototxt')
    # Do we need the deploy?
    parser.add_argument(
        '--deploy',
        default='models/bvlc_alexnet/deploy.prototxt')

    args = parser.parse_args()
    args.snapshot_prefix = args.snapshot_prefix.format(
        output=args.output, bitmask=args.bitmask)

    bitmask = args.bitmask
    assert len(bitmask) == len(LAYERS), (
        'Expected {} bits in bitmask, received {}.'.format(
            len(LAYERS), len(bitmask)))
    try:
        int(bitmask)
    except ValueError:
        raise Exception('Invalid bitmask: {}'.format(bitmask))

    zeroed_layers = set(layer for i, layer in enumerate(LAYERS)
                        if bitmask[i] == '0')

    # Parse solver
    solver = SolverParameter()
    parse_prototxt(solver, args.solver)
    solver.snapshot_prefix = args.snapshot_prefix
    solver.net = '{}/train_val.prototxt'.format(args.output)

    # Parse trainval NetParameter
    trainval = NetParameter()
    parse_prototxt(trainval, args.trainval)

    for layer in trainval.layer:
        if layer.name in zeroed_layers:
            print('Zeroing {}'.format(layer.name))
            for param in layer.param:
                param.lr_mult = 0
                param.decay_mult = 0

    mkdir_p(args.output)
    write_prototxt(trainval, '{}/train_val.prototxt'.format(args.output))
    write_prototxt(solver, '{}/solver.prototxt'.format(args.output))
    copyfile(args.deploy, '{}/deploy.prototxt'.format(args.output))


if __name__ == "__main__":
    main()
