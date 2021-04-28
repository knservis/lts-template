#!/bin/bash

FILE_LIST=$1

# Submit to copyq and get job id for next step
JOB_ID=$(sbatch -p copyq -M zeus \
            --export=RCLONE_CONFIG_CEPH_SECRET_ACCESS_KEY,RCLONE_CONFIG_CEPH_ACCESS_KEY_ID \
            sync.sh ceph:lts-template/data $MYSCRATCH/lts-template/data $FILE_LIST \
            | perl -ne 'm/(\d+).*$/g; print $1;' )
echo "Scheduled sync-in JOB_ID: $JOB_ID"

# Keeping it simple just running for one file
FILE=$(head -1 $FILE_LIST)
XY_FILE=${FILE/.fits/_crop.xy}
# Right ascension of object of interest
RA_OBJECT=0.1 
# Declination of object of interest
DEC_OBJECT=0.25 

JOB_ID2=$(sbatch -p debugq -M magnus -d afterok:$JOB_ID \
    get_world_2_pix.sh $MYSCRATCH/lts-template/data/$FILE \
                       $RA_OBJECT $DEC_OBJECT \
                       $MYSCRATCH/lts-template/data/$XY_FILE \
    | perl -ne 'm/(\d+).*$/g; print $1;' )
echo "Scheduled sky2xy JOB_ID: $JOB_ID2"

OUTPUT_FILE=${FILE/.fits/_crop.fits}

# Label (a string e.g. ngc123 ) of object of interest
LABEL_OBJECT=galaxy_1
# Number of pixels around object of interest to crop 
PIXELS_AROUND_CENTRE=20

# This script will assume there is only one object and one set of coordinates
JOB_ID3=$(sbatch -p debugq -M magnus -d afterok:$JOB_ID2 \
    crop_image_around_pixels.sh $MYSCRATCH/lts-template/data/$FILE \
                                $MYSCRATCH/lts-template/data/$OUTPUT_FILE \
                                $MYSCRATCH/lts-template/data/$XY_FILE \
                                $LABEL_OBJECT \
                                $PIXELS_AROUND_CENTRE \
    | perl -ne 'm/(\d+).*$/g; print $1;' )
echo "Scheduled crop JOB_ID: $JOB_ID3"

echo "$MYSCRATCH/lts-template/data/$OUTPUT_FILE" > sync_back_list.txt

# Submit to copyq and get job id for next step
JOB_ID4=$(sbatch -p copyq -M zeus -d afterok:$JOB_ID3 \
            --export=RCLONE_CONFIG_CEPH_SECRET_ACCESS_KEY,RCLONE_CONFIG_CEPH_ACCESS_KEY_ID \
            sync.sh $MYSCRATCH/lts-template/data ceph:lts-template/data sync_back_list.txt \
            | perl -ne 'm/(\d+).*$/g; print $1;' )
echo "Scheduled sync-in JOB_ID: $JOB_ID4"

# You could add another job here to perform other tasks (such as reporting back to an external job queue or housekeeping)
