#!/bin/sh

if [ "${COMPRESSED}" = "true" ]; then
    FILE_NAME=/tmp/$BACKUP_NAME-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz
    echo "creating archive"
    tar -zcvf ${FILE_NAME} /data
    echo "uploading archive to S3 ..."
    aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp ${FILE_NAME} ${S3_BUCKET_URL}
    echo "removing local archive"
    rm ${FILE_NAME}
    echo "done"
else
    echo "uploading files to S3 ..."
    DATE=`date "+%Y-%m-%d"`
    if [ "${DELETE}" = "true" ]; then
        aws --endpoint-url ${AWS_ENDPOINT_URL} s3 sync --delete /data ${S3_BUCKET_URL}/${DATE}
    else
        aws --endpoint-url ${AWS_ENDPOINT_URL} s3 sync /data ${S3_BUCKET_URL}/${DATE}
    fi
fi

if [ "${RETENTION_DAYS}" ]; then
    echo "We're cleaning up files older than ${RETENTION_DAYS} day(s)"
    $olderThanSecs=$( expr ${RETENTION_DAYS} \* 86400 )
    aws --endpoint-url ${AWS_ENDPOINT_URL} s3 ls ${S3_BUCKET_URL} | while read -r line;
    do
      createDate=$(echo $line|awk {'print $1" "$2'})
      createDate=$(date -d"$createDate" +%s)
      olderThan=$(date -d@"$(( `date +%s`-olderThanSecs))" +%s)
      if [[ $createDate -lt $olderThan ]]
      then
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]
        then
          aws --endpoint-url ${AWS_ENDPOINT_URL} s3 rm ${S3_BUCKET_URL}/$fileName
        fi
      fi
    done;
fi
