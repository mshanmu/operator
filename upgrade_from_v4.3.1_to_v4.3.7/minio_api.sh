#!/bin/bash
DATE=`date -R`
: "${MINIO_BUCKET:=test2}"
: "${MINIO_HOST:=minio.minio-tenant-1.svc.cluster.local}"
: "${MINIO_USER:=minio}"
: "${MINIO_PASS:=minio123}"
MINIO_FILE="minio_api.sh"
CONTENT_TYPE="application/octet-stream"
RAW_SIG="PUT\n\n${CONTENT_TYPE}\n${DATE}\n/${MINIO_BUCKET}/${MINIO_FILE}"
ENC_SIG=`echo -en ${RAW_SIG} | openssl sha1 -hmac ${MINIO_PASS} -binary | base64`
curl -vvv -X PUT -T ${MINIO_FILE} \
	-H "Host: ${MINIO_HOST}" \
	-H "Date: ${DATE}" \
	-H "Content-Type: ${CONTENT_TYPE}" \
	-H "Authorization: AWS ${MINIO_USER}:${ENC_SIG}" \
	-H "Accept-Encoding: gzip" \
	http://${MINIO_HOST}/${MINIO_BUCKET}/${MINIO_FILE}
