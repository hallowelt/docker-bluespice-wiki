FROM alpine:3 AS builder

# We use SimpleSAMLphp SLIM version
ENV SIMPLESAMLPHP_VERSION=2.4.3
ENV SIMPLESAMLPHP_URL=https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SIMPLESAMLPHP_VERSION}/simplesamlphp-${SIMPLESAMLPHP_VERSION}-slim.tar.gz
ENV SIMPLESAMLPHP_SHA256=bf281c486bedc0b82d02757c292216fd6e1a569bcb0300ae3ab0cacdab6a718e

ARG BLUESPICE_VERSION=5.1.3
ARG BLUESPICE_EDITION=free
ARG BLUESPICE_URL=https://github.com/BlueSpice-Wiki/bluespice-free-release/releases/download/${BLUESPICE_VERSION}/bluespice-free-${BLUESPICE_VERSION}.tar.gz
ARG BLUESPICE_SHA256=849aad00aabc5b90853760fc0fcbdf75ac71a24b0cdec988f796548c25c92328

WORKDIR /build
RUN apk add --no-cache \
	ca-certificates \
	tar \
	wget \
	&& mkdir -p /build/simplesamlphp \
	&& mkdir -p /build/bluespice \
	&& wget -O simplesamlphp.tar.gz $SIMPLESAMLPHP_URL \
	&& echo "${SIMPLESAMLPHP_SHA256} simplesamlphp.tar.gz" | sha256sum -c - \
	&& tar -xzf simplesamlphp.tar.gz -C /build/simplesamlphp --strip-components 1 \
	&& rm simplesamlphp.tar.gz \
	&& wget -O bluespice.tar.gz $BLUESPICE_URL \
	&& echo "${BLUESPICE_SHA256} bluespice.tar.gz" | sha256sum -c - \
	&& tar -xzf bluespice.tar.gz -C /build/bluespice --strip-components 1 \
	&& rm bluespice.tar.gz

FROM alpine:3 AS base
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV VERSION=84
RUN apk add \
	bash \
	openssl \
	clamav-clamdscan \
	ca-certificates \
	imagemagick \
 	libc6-compat \
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
 	php$VERSION-tokenizer \
	poppler-utils \
	procps \
	python3 \
	rsvg-convert \
	supercronic \
	tzdata \
	vim \
	&& echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk add php$VERSION-pecl-excimer@testing
RUN echo "@edge https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
	&& apk add openjpeg@edge
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
COPY --chown=$USER:$GROUPNAME --from=builder /build/bluespice /app/bluespice/w
COPY --chown=$USER:$GROUPNAME --from=builder /build/simplesamlphp /app/simplesamlphp
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
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf

ARG EDITION
RUN if [ -n "$EDITION" ]; then \
		echo "EDITION=$EDITION" > /app/.env; \
	fi

RUN ln -sf /usr/sbin/php-fpm$VERSION /usr/bin/php-fpm \
	&& mkdir /var/run/php \
	&& ln -sf /usr/bin/php$VERSION /usr/bin/php \
	&& ln -sf /usr/bin/php$VERSION /bin/php \
	&& mkdir -p /etc/nginx/sites-enabled \
	&& ln -s /app/conf/90-bluespice-overrides.ini /etc/php$VERSION/conf.d/90-bluespice-overrides.ini \
	&& ln -s /app/conf/nginx_bluespice /etc/nginx/sites-enabled/default \
	&& chown -R $USER:$GROUPNAME /var/run/php \
	&& mkdir -p /etc/clamav/ \
	&& ln -s /app/bin/config/clamd.conf /etc/clamav/clamd.conf
FROM bluespice-prepare AS bluespice-final
WORKDIR /app
USER bluespice
EXPOSE 9090
HEALTHCHECK --interval=30s --timeout=5s CMD probe-liveness
ENTRYPOINT ["/app/bin/entrypoint"]
