#!/bin/bash

# e.g. paths (input or output):
# "ceph:lts-template/data"
# "$MYSCRATCH/lts-template/data"

FROM_PATH=$1
TO_PATH=$2
FILE_LIST=$([ "$3" == "" ] && echo "" || echo "--files-from="$(realpath $3)) # optional list of files to avoid syncing everything in the source

module load rclone 

# Setup remote
export RCLONE_CONFIG_CEPH_TYPE="s3"
# Following endpoint likely to change (possibly the port) when the prod system is launched
export RCLONE_CONFIG_CEPH_ENDPOINT="https://nimbus.pawsey.org.au:8080"

# For non-public resources you will need your credentials in this script or the environment e.g.:
# export RCLONE_CONFIG_CEPH_ACCESS_KEY_ID="deadbeefdeadbeefdeadbeef"
# export RCLONE_CONFIG_CEPH_SECRET_ACCESS_KEY="deadbeefdeadbeefdeadbeef"
 
rclone sync $FILE_LIST $FROM_PATH $TO_PATH 
