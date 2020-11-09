#!/bin/sh

if [ "${COMPRESSED}" = "true" ]; then
    FILE_NAME=/tmp/$BACKUP_NAME-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz
    echo "creating archive"
    tar -zcvf ${FILE_NAME} /data
    echo "uploading archive to S3 [${FILE_NAME}]"
    aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp ${FILE_NAME} ${S3_BUCKET_URL}
    echo "removing local archive"
    rm ${FILE_NAME}
    echo "done"
else
    echo "uploading files to S3 [${FILE_NAME}]"
    DATE=`date "+%Y-%m-%d"`
    if [ "${DELETE}" = "true" ]; then
        aws --endpoint-url ${AWS_ENDPOINT_URL} s3 sync --delete /data ${S3_BUCKET_URL}/${DATE}
    else
        aws --endpoint-url ${AWS_ENDPOINT_URL} s3 sync /data ${S3_BUCKET_URL}/${DATE}
    fi
fi

