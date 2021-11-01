FROM alpine:3.13
MAINTAINER serenity <serenitysir@outlook.com>

ENV NPS_VERSION 0.26.9
# ${uname -m}
ENV MACHINE arm64 

RUN set -x && \
	wget --no-check-certificate https://github.com/ehang-io/nps/releases/download/v${NPS_VERSION}/linux_${MACHINE}_server.tar.gz && \ 
    mkdir /nps && \
	tar xzf linux_${MACHINE}_server.tar.gz -C /nps && \
	cd /nps && \
	cd .. && \
	rm -rf *.tar.gz

WORKDIR /nps
VOLUME /nps/conf

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
