FROM alpine:latest

COPY entrypoint.sh /
COPY dobackup.sh /

RUN \
	mkdir -p /aws && \
	mkdir -p /data && \
	apk -Uuv add groff less python3 py3-pip && \
	pip3 install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/* && \
	wget -P /usr/bin https://dl.min.io/client/mc/release/linux-amd64/mc && \
	chmod +x /usr/bin/mc && \
	chmod +x /entrypoint.sh /dobackup.sh


ENTRYPOINT /entrypoint.sh
