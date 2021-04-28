#!/bin/bash

INPUT_FILE_NAME=$1
RA=$2
DEC=$3
OUTPUT_FILE_NAME=$4

DOCKER_IMAGE=curtinfop/wcstools

module load singularity

singularity run docker://$DOCKER_IMAGE sky2xy \
        $INPUT_FILE_NAME \
        $RA $DEC > $OUTPUT_FILE_NAME    