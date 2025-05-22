FROM alpine:3 AS base
ENV TZ=CET
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
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
	php-fpm \
	php-xml \
	php-mbstring \
	php-curl \
	php-zip \
	php-cli \
	php-json \
	php-mysqli \
	php-ldap \
	php-opcache \
	php-apcu \
	php-intl \
	php-gd \
	php-gmp \
	php-ctype \
	php-iconv \
	php-fileinfo \
	php-xml \
	php-xmlreader \
	php-xmlwriter \
	php-simplexml \
	php-session \
	php-phar \
	php-pdo \
	php-pdo_mysql \
	php-posix \
	poppler-utils \
	python3 \
	vim \
	rsvg-convert \
	&& echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk add php83-pecl-excimer@testing
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
ADD --chown=$USER:$GROUPNAME --chmod=755 https://raw.githubusercontent.com/hallowelt/docker-bluespice-formula/main/_client/mathoid-remote /app/bin
ADD --chown=$USER:$GROUPNAME --chmod=755 https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm /app/bin
ADD --chown=$USER:$GROUPNAME --chmod=755 https://github.com/hallowelt/misc-parallel-runjobs-service/releases/download/2.0.0/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php83
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php83/php-fpm.d/
COPY ./root-fs/etc/php/8.x/fpm/conf.d/* /etc/php83/conf.d/
COPY ./root-fs/etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /usr/sbin/php-fpm83 /usr/bin/php-fpm \
	&& mkdir /var/run/php \
	&& ln -sf /usr/bin/php /bin/php \
	&& chown -R $USER:$GROUPNAME /var/run/php


FROM bluespice-prepare AS bluespice-final
WORKDIR /app
USER bluespice
EXPOSE 9090
HEALTHCHECK --interval=30s --timeout=5s CMD probe-liveness
ENTRYPOINT ["/app/bin/entrypoint"]
#ENTRYPOINT ["sleep", "infinity"]
