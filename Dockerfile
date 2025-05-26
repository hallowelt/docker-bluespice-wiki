FROM alpine:3.21 AS base
ENV TZ=CET
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV VERSION=84
RUN apk add \
	bash \
	openssl \
	clamav-clamdscan \
	ca-certificates \
	imagemagick \
	ghostscript \
	xpdf \
	nginx \
	php \
	php$VERSION-fpm \
	php$VERSION-xml \
	php$VERSION-mbstring \
	php$VERSION-curl \
	php$VERSION-zip \
	php$VERSION-cli \
	php$VERSION-json \
	php$VERSION-mysqli \
	php$VERSION-ldap \
	php$VERSION-opcache \
	php$VERSION-apcu \
	php$VERSION-intl \
	php$VERSION-gd \
	php$VERSION-gmp \
	php$VERSION-ctype \
	php$VERSION-iconv \
	php$VERSION-fileinfo \
	php$VERSION-xml \
	php$VERSION-xmlreader \
	php$VERSION-xmlwriter \
	php$VERSION-simplexml \
	php$VERSION-session \
	php$VERSION-phar \
	php$VERSION-pdo \
	php$VERSION-pdo_mysql \
	php$VERSION-posix \
	poppler-utils \
	procps \
	python3 \
	rsvg-convert \
	supercronic \
	vim \
	&& echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk add php84-pecl-excimer@testing
FROM base AS bluespice-prepare
ENV PATH="/app/bin:${PATH}"
ARG UID
ENV UID=1002
ARG USER
ENV USER=bluespice
ENV PATH="/app/bin:${PATH}"
ARG GID
ENV GID=$UID
ARG GROUPNAME
ENV GROUPNAME=$USER

RUN addgroup -g $GID $GROUPNAME \
	&& adduser -u $UID -G $GROUPNAME --shell /bin/bash --disabled-password --gecos "" $USER \
	&& addgroup $USER nginx \
	&& mkdir -p /app/bluespice \
	&& chown $USER:$GROUPNAME /app/bluespice/ \
	&& chmod -R 777 /var/log
COPY --chown=$USER:$GROUPNAME ./_codebase/bluespice /app/bluespice/w
COPY --chown=$USER:$GROUPNAME ./_codebase/simplesamlphp/ /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME --chmod=755 ./root-fs/app/bin /app/bin
COPY --chown=$USER:$GROUPNAME --chmod=666 ./root-fs/app/bin/config /app/bin/config
COPY --chown=$USER:$GROUPNAME ./root-fs/app/conf /app/conf
COPY --chown=$USER:$GROUPNAME ./root-fs/app/simplesamlphp/ /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME ./root-fs/app/cron /app/cron
ADD --chown=$USER:$GROUPNAME --chmod=755 https://raw.githubusercontent.com/hallowelt/docker-bluespice-formula/main/_client/mathoid-remote /app/bin
ADD --chown=$USER:$GROUPNAME --chmod=755 https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm /app/bin
ADD --chown=$USER:$GROUPNAME --chmod=755 https://github.com/hallowelt/misc-parallel-runjobs-service/releases/latest/download/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php$VERSION
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php$VERSION/php-fpm.d/
COPY ./root-fs/etc/php/8.x/fpm/conf.d/* /etc/php$VERSION/conf.d/
COPY ./root-fs/etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /usr/sbin/php-fpm$VERSION /usr/bin/php-fpm \
	&& mkdir /var/run/php \
	&& ln -sf /usr/bin/php84 /usr/bin/php \
	&& ln -sf /usr/bin/php84 /bin/php \
	&& chown -R $USER:$GROUPNAME /var/run/php


FROM bluespice-prepare AS bluespice-final
WORKDIR /app
USER bluespice
EXPOSE 9090
HEALTHCHECK --interval=30s --timeout=5s CMD probe-liveness
ENTRYPOINT ["/app/bin/entrypoint"]
