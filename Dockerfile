FROM composer:2 AS workaround-erm-45965
# Build SimpleSAMLphp from source, bypassing the original way of loading
ENV SIMPLESAMLPHP_VERSION=2.3.10
WORKDIR /build
RUN git clone https://github.com/simplesamlphp/simplesamlphp.git -b v${SIMPLESAMLPHP_VERSION} /build/simplesamlphp && \
	cd /build/simplesamlphp && \
	composer require psr/http-message:^1.1 psr/container:^1.1 --update-no-dev --prefer-dist --optimize-autoloader && \
	rm -rf /build/simplesamlphp/.git

FROM alpine:3 AS builder

# We use SimpleSAMLphp SLIM version to reduce the image size
ENV SIMPLESAMLPHP_VERSION=2.4.4
ENV SIMPLESAMLPHP_URL=https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SIMPLESAMLPHP_VERSION}/simplesamlphp-${SIMPLESAMLPHP_VERSION}-slim.tar.gz
ENV SIMPLESAMLPHP_SHA256=1c351342293d218447b27df9a03d2da7561d3831303524c173e8974b3168a57e

ENV MATHOIDREMOTE_URL=https://raw.githubusercontent.com/hallowelt/docker-bluespice-formula/5.1.x/_client/mathoid-remote
ENV MATHOIDREMOTE_SHA256=9a562346e8fcc662f2d4b1c2a674c23862782365807d30de317a1fe77affc36a

ENV MEDIAWIKIADM_URL=https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm
ENV MEDIAWIKIADM_SHA256=c038de94ce49c66584556bc03c58bf0f9388d109b9428c800d0b74c90b528f15

ENV PARALLELRUNJOBSSERVICE_URL=https://github.com/hallowelt/misc-parallel-runjobs-service/releases/latest/download/parallel-runjobs-service
ENV PARALLELRUNJOBSSERVICE_SHA256=ec8ea7e8a79242baba862448bcba952376267c0db19785d6266ab9a01a29e241

ARG BLUESPICE_VERSION=5.2.2
ARG BLUESPICE_URL=https://github.com/BlueSpice-Wiki/bluespice-free-release.git

WORKDIR /build
ADD --checksum=sha256:${SIMPLESAMLPHP_SHA256} ${SIMPLESAMLPHP_URL} /build/simplesamlphp.tar.gz
ADD --checksum=sha256:${MATHOIDREMOTE_SHA256} ${MATHOIDREMOTE_URL} /build/mathoid-remote
ADD --checksum=sha256:${MEDIAWIKIADM_SHA256} ${MEDIAWIKIADM_URL} /build/mediawiki-adm
ADD --checksum=sha256:${PARALLELRUNJOBSSERVICE_SHA256} ${PARALLELRUNJOBSSERVICE_URL} /build/parallel-runjobs-service
# HINT: Based on the type of URL, this can already be a tarball ( "Release-URL" ) or a git repository checkout ( "pre-release"/"custom-edition" )
ADD ${BLUESPICE_URL}#${BLUESPICE_VERSION} /build/bluespice

RUN mkdir -p /build/simplesamlphp && \
	tar -xzf /build/simplesamlphp.tar.gz -C /build/simplesamlphp --strip-components=1
RUN rm -rf /build/.git

FROM alpine:3 AS base
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV VERSION=84
RUN apk add \
	bash \
	ca-certificates \
	clamav-clamdscan \
	ghostscript \
	imagemagick \
	libc6-compat \
	nginx \
	openssl \
	php \
	php$VERSION-apcu \
	php$VERSION-cli \
	php$VERSION-ctype \
	php$VERSION-curl \
	php$VERSION-fileinfo \
	php$VERSION-fpm \
	php$VERSION-gd \
	php$VERSION-gmp \
	php$VERSION-iconv \
	php$VERSION-intl \
	php$VERSION-json \
	php$VERSION-ldap \
	php$VERSION-mbstring \
	php$VERSION-mysqli \
	php$VERSION-opcache \
	php$VERSION-pdo \
	php$VERSION-pdo_mysql \
	php$VERSION-pdo_pgsql \
	php$VERSION-pdo_sqlite \
	php$VERSION-pgsql \
	php$VERSION-phar \
	php$VERSION-posix \
	php$VERSION-session \
	php$VERSION-simplexml \
	php$VERSION-sqlite3 \
	php$VERSION-tokenizer \
	php$VERSION-xml \
	php$VERSION-xmlreader \
	php$VERSION-xmlwriter \
	php$VERSION-zip \
	poppler-utils \
	procps \
	python3 \
	rsvg-convert \
	supercronic \
	tzdata \
	vim \
	xpdf \
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
COPY --chown=$USER:$GROUPNAME --from=workaround-erm-45965 /build/simplesamlphp /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME --chmod=755 ./root-fs/app/bin /app/bin
COPY --chown=$USER:$GROUPNAME --chmod=666 ./root-fs/app/bin/config /app/bin/config
COPY --chown=$USER:$GROUPNAME ./root-fs/app/conf /app/conf
COPY --chown=$USER:$GROUPNAME ./root-fs/app/simplesamlphp/ /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME ./root-fs/app/cron /app/cron
COPY --chown=$USER:$GROUPNAME --from=builder --chmod=755 /build/mathoid-remote /app/bin
COPY --chown=$USER:$GROUPNAME --from=builder --chmod=755 /build/mediawiki-adm /app/bin
COPY --chown=$USER:$GROUPNAME --from=builder --chmod=755 /build/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php$VERSION
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php$VERSION/php-fpm.d/
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf

ARG EDITION # Intentionally left uninitialized
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
	&& ln -s /app/bin/config/clamd.conf /etc/clamav/clamd.conf \
	&& touch /app/.env \
	&& chown $USER:$GROUPNAME /app/.env \
	&& chmod 660 /app/.env
FROM bluespice-prepare AS bluespice-final

# Antivirus service defaults
ENV AV_HOST="-"
ENV AV_PORT="3310"

# Backup defaults
ENV BACKUP_HOUR="1"

# Cache service defaults
ENV CACHE_HOST="cache"
ENV CACHE_PORT="11211"

# Chat defaults
ENV CHAT_HOST="chat"
ENV CHAT_PORT="3000"
ENV CHAT_PROTOCOL="http"

# Database defaults
ENV DB_HOST="database"
ENV DB_NAME="bluespice"
ENV DB_PREFIX=""
ENV DB_ROOT_PASS=""
ENV DB_ROOT_USER="root"
ENV DB_TYPE="mysql"
ENV DB_USER="bluespice"

# Development/Debug defaults
ENV DEV_WIKI_DEBUG=""
ENV DEV_WIKI_DEBUG_LOGCHANNELS=""

# Formula service defaults
ENV FORMULA_HOST="formula"
ENV FORMULA_PORT="10044"
ENV FORMULA_PROTOCOL="http"

# PDF service defaults
ENV PDF_HOST="pdf"
ENV PDF_PORT="8080"
ENV PDF_PROTOCOL="http"

# Search service defaults
ENV SEARCH_HOST="search"
ENV SEARCH_PASS=""
ENV SEARCH_PORT="9200"
ENV SEARCH_PROTOCOL="http"
ENV SEARCH_USER=""

# SMTP defaults
ENV SMTP_HOST=""
ENV SMTP_IDHOST=""
ENV SMTP_PASS=""
ENV SMTP_PORT="25"
ENV SMTP_USER=""

# Timezone defaults
ENV TZ="UTC"

# Wiki defaults
ENV WIKI_BASE_PATH="/"
ENV WIKI_EMERGENCYCONTACT=""
ENV WIKI_FARM_DB_PREFIX="sfr_"
ENV WIKI_FARM_USE_SHARED_DB=""
ENV WIKI_HOST="localhost"
ENV WIKI_INITIAL_ADMIN_PASS=""
ENV WIKI_INITIAL_ADMIN_USER="Admin"
ENV WIKI_LANG="en"
ENV WIKI_LOG_LEVEL="error"
ENV WIKI_NAME="BlueSpice"
# Ignore SecretsUsedInArgOrEnv as this is only a path
ENV WIKI_OAUTH2_PRIVATE_KEY_FILE="/data/bluespice/oauth_private.key"
ENV WIKI_OAUTH2_PUBLIC_KEY_FILE="/data/bluespice/oauth_public.key"
ENV WIKI_PORT="443"
ENV WIKI_POST_INIT_SETTINGS_FILE="/data/bluespice/post-init-settings.php"
ENV WIKI_PRE_INIT_SETTINGS_FILE="/data/bluespice/pre-init-settings.php"
ENV WIKI_PROTOCOL="https"
# Ignore SecretsUsedInArgOrEnv as this is not sensitive
ENV WIKI_SUBSCRIPTION_KEY=""
ENV WIKI_STATUSCHECK_ALLOWED=""

# Diagram defaults
ENV DIAGRAM_PATH="/_diagram/"
ENV DIAGRAM_HOST=""
ENV DIAGRAM_PORT=""
ENV DIAGRAM_PROTOCOL=""

# Wire defaults
ENV WIRE_HOST="wire"
ENV WIRE_PORT="3333"
ENV WIRE_PROTOCOL="http"

WORKDIR /app
USER bluespice
EXPOSE 9090
HEALTHCHECK --interval=30s --timeout=5s CMD probe-liveness
ENTRYPOINT ["/app/bin/entrypoint"]
