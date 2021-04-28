#!/bin/bash


INPUT_FILE_NAME=$1
OUTPUT_FILE_NAME=$2
XY_FILE_NAME=$3
OBJ_ID=$4
WIDTH_IN_PIXELS=$5

module load singularity

DOCKER_IMAGE=curtinfop/gnuastro

CENTRE_COORDINATES=$(perl -lne '/(off image|offscale)/ and exit 1 or @a=split /\s+/ and print join ",", @a[4..5];' < $XY_FILE_NAME)

# If there is more than one set of coordinates this needs to become a loop

singularity run docker://$DOCKER_IMAGE astcrop \
                                    -o $OUTPUT_FILE_NAME \
                                    -h0 \
                                    --mode=img \
                                    --center=$CENTRE_COORDINATES \
                                    --width=$WIDTH_IN_PIXELS \
                                    $INPUT_FILE_NAME
                                    