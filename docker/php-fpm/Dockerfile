FROM phpdockerio/php:8.1-fpm

WORKDIR "/hbmon"

RUN apt-get update; \
    apt-get -y --no-install-recommends install \
        php8.1-mysql  libmariadb-dev-compat

RUN apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN git clone https://github.com/yuvelq/FDMR-Monitor.git /hbmon && \
	cd FDMR-Monitor
	git checkout Self_Service


