FROM phpdockerio/php:8.1-fpm

WORKDIR "/hbmon"

COPY entrypoint /entrypoint

RUN adduser -u 54001 hbmon

RUN apt-get update; \
    apt-get -y --no-install-recommends install \
        php8.1-mysql  libmariadb-dev-compat \
        gcc git musl-dev libffi-dev libssl-dev cargo python3 python3-pip python3-dev

RUN apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN git clone https://github.com/yuvelq/FDMR-Monitor.git /hbmon && \
	git checkout Self_Service

RUN cd /hbmon && pip3 install --no-cache-dir -r requirements.txt 

USER hbmon

ENTRYPOINT [ "/entrypoint" ]
