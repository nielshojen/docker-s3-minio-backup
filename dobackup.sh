#!/bin/sh

# generate file name for tar
FILE_NAME=/tmp/$BACKUP_NAME-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz

echo "creating archive"
tar -zcvf ${FILE_NAME} /data
echo "uploading archive to S3 [${FILE_NAME}]"
aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp ${FILE_NAME} ${S3_BUCKET_URL}
echo "removing local archive"
rm ${FILE_NAME}
echo "done"
