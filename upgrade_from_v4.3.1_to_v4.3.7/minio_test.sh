#!/bin/sh
declare -a FILE_ARRAY
declare -a SUCCESS_ARRAY
declare -a FAILURE_ARRAY
MINIO_ALIAS=minio
MINIO_BUCKET=test4
BS=8192
DEBUG=false
GENERATE_FILE_LIST=("435 B" "10 K" "1 M" "10 M" "100 M" "1 G")

function rfile() {
    local SIZE=$1
    local bs=$BS

    if [ $SIZE -lt $bs ]
    then
        COUNT=1
        bs=$SIZE
    else
        COUNT=`expr $SIZE / $BS`
    fi

    local unit=$(numfmt --to iec $SIZE)

    FILE=$(mktemp --suffix="-SZ-$unit")
    dd if=/dev/urandom of=$FILE bs=$BS count=$COUNT
    FILE_ARRAY+=($FILE)
}

function calcBytes() {
    VAL=$1
    PAR=$2
    case $PAR in 
        B)
        let "val=$VAL"
        ;;
        K)
        let "val=$VAL * 1024"
        ;;
        M)
        let "val=$VAL * 1024 * 1024"
        ;;
        G)
        let "val=$VAL * 1024 * 1024 * 1024"
        ;;
    esac

    echo "$val"
}

function generateFiles() {
  # Create the large files
  echo "Generating random files..."

  for i in "${GENERATE_FILE_LIST[@]}"
  do
     local val=$(echo $i | cut -f1 -d" ")
     local unit=$(echo $i | cut -f2 -d" ")
     rfile $(calcBytes $val $unit)
  done

  echo
}

function MC() {
    if [ "$DEBUG" = "true" ]
    then
        mc $1 --debug
    else
        mc $1
    fi
    
    if [ $? -eq 0 ]
    then
    	SUCCESS_ARRAY+=($2)
    else
	echo "FAILED."
	FAILURE_ARRAY+=($2)
    fi
}

function copyFiles() {
    # Transfer the large files
    echo "Transferring the files into MinIO bucket"
    echo

    for i in "${FILE_ARRAY[@]}"
    do
       echo "Processing file: $i"
       echo
       MC "cp $i $MINIO_ALIAS/$MINIO_BUCKET" "Copying file $i:"
       echo
    done
}

function downloadFiles() {
    # Download the same files
    echo "Download the same files from MinIO bucket"
    echo
    for i in "${FILE_ARRAY[@]}"
    do
       echo "Processing file: $i"
       echo
       BASE=$(basename $i)
       local msg="Downloading file $BASE ...:"
       mc cat $MINIO_ALIAS/$MINIO_BUCKET/$BASE > ${i}.new
       if [ $? -eq 0 ]
       then
    	  SUCCESS_ARRAY+=($msg)
       else
	  echo "FAILED."
	  FAILURE_ARRAY+=($msg)
       fi
       echo
    done
}

function cksumComparison() {
    # Compare the checksum
    echo "Checksum comparison"
    echo
    for i in "${FILE_ARRAY[@]}"
    do
       echo "Processing file: $i"
       echo
       OLD=$(cksum $i)
       NEW=$(cksum ${i}.new)
       CKSUM_OLD=$(echo $OLD | cut -f1 -d' ') 
       CKSUM_NEW=$(echo $NEW | cut -f1 -d' ') 
       local success=1
       if [ $CKSUM_OLD != $CKSUM_NEW ]
       then
	  local msg="File $i has wrong cksum:"
          echo "$msg FAILED."
	  FAILURE_ARRAY+=($msg)
	  success=0
       fi
       BYTES_OLD=$(echo $OLD | cut -f2 -d' ')
       BYTES_NEW=$(echo $NEW | cut -f2 -d' ')
       if [ $BYTES_OLD != $BYTES_NEW ]
       then
          local msg="File $i has wrong size:"
          echo "$msg FAILED."
	  FAILURE_ARRAY+=($msg)
	  success=0
       fi

       [ $success -eq 1 ] && {
	 local msg="Verified file $i:" 
	 SUCCESS_ARRAY+=($msg)
       }
	
    done
}

function deleteFiles() {
    # Delete the large files
    echo "Deleting the files..."
    echo
    for i in "${FILE_ARRAY[@]}"
    do
       echo "Processing file: $i"
       echo
       BASE=$(basename $i)
       MC "rm $MINIO_ALIAS/$MINIO_BUCKET/$BASE" "Deleting file $BASE:"
       rm -f $i
       rm -f ${i}.new
       echo
    done
}

function createBucket() {
    # Create bucket
    MC "mb $MINIO_ALIAS/$MINIO_BUCKET" "Creating bucket:"
}

function deleteBucket() {
    # Create bucket
    MC "rb $MINIO_ALIAS/$MINIO_BUCKET" "Deleting bucket:"
}

function testAcceptEncodingGzip() {
    MINIO_BUCKET=$MINIO_BUCKET MINIO_FILE="minio_api.sh" ./minio_api.sh
    local msg="PUT Gzip accept encoding file: "
    if [ $? -ne 0 ] 
    then
        echo "$msg FAILED."
	FAILURE_ARRAY+=($msg)
    else
	SUCCESS_ARRAY+=($msg)
    fi
    MC "rm $MINIO_ALIAS/$MINIO_BUCKET/minio_api.sh" "Deleting Gzip accept encoding file:"
}

# Main
createBucket
generateFiles
copyFiles
downloadFiles
cksumComparison
deleteFiles
testAcceptEncodingGzip
deleteBucket

echo 
echo "Results:"
echo 

IFS=':'
/usr/bin/printf " "
success=1
for i in `echo "${SUCCESS_ARRAY[@]}"`
do
   /usr/bin/printf "$i \033[0;32m \u2714 \033[0m \n"
done

for i in `echo "${FAILURE_ARRAY[@]}"`
do
   /usr/bin/printf "$i \033[0;31m \u2718 \033[0m \n"
   success=0
done

echo

[ $success -eq 1 ] && printf "\033[0;32m COMPLETE SUCESS. \033[0m \n\n"

exit 0
