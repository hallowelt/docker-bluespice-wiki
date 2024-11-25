FROM debian:bookworm-slim AS base
ENV TZ=CET
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
	&& apt-get update  \
	&& apt-get -y install --no-install-recommends gnupg2 curl  \
	&& touch /etc/apt/sources.list.d/trixie.list && printf "deb http://deb.debian.org/debian trixie main" > /etc/apt/sources.list.d/trixie.list \
	&& apt-get update \
	&& apt-get --only-upgrade install zlib1g

FROM base AS bluespice-main
RUN apt-get -y --no-install-recommends install \
	openssl \
	ca-certificates \
	imagemagick \
	nginx \
	php \
	php-fpm \
	php-xml \
	php-mbstring \
	php-curl \
	php-zip \
	php-cli \
	php-json \
	php-mysql \
	php-ldap \
	php-opcache \
	php-apcu \
	php-intl \
	php-gd \
	php-gmp \
	poppler-utils \
	python3 \
	librsvg2-bin \
	vim.tiny \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

FROM bluespice-main AS bluespice-prepare
ARG UID
ENV UID=1002
ARG USER
ENV USER=bluespice
ARG GID
ENV GID=$UID
ARG GROUPNAME
ENV GROUPNAME=$USER
RUN addgroup -gid $GID $GROUPNAME \
	&& adduser -uid $UID -gid $GID --disabled-password --gecos "" $USER \
	&& usermod -aG www-data $USER \
	&& mkdir -p /app/bluespice \
	&& cd /app/bluespice \
	&& chown -R $UID:www-data /var/run/php \
	&& mkdir -p /var/lib/nginx \
	&& chown -R $UID:www-data /var/lib/nginx \
	&& chmod -R 777 /var/lib/nginx
COPY --chown=www-data:www-data ./_codebase/bluespice /app/bluespice/w
COPY --chown=$USER:$GROUPNAME ./_codebase/simplesamlphp/ /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME --chmod=755 ./root-fs/app/bin /app/bin
COPY --chown=$USER:$GROUPNAME ./root-fs/app/conf /app/conf
COPY --chown=www-data:www-data ./root-fs/app/simplesamlphp /app
ADD --chown=$USER:$GROUPNAME https://raw.githubusercontent.com/hallowelt/docker-bluespice-formula/main/_client/mathoid-remote /app/bin
ADD --chown=$USER:$GROUPNAME https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm /app/bin
ADD --chown=$USER:$GROUPNAME https://github.com/hallowelt/misc-parallel-runjobs-service/releases/download/2.0.0/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/conf.d/* /etc/php/8.2/fpm/conf.d
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php/8.2/fpm/
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/
COPY ./root-fs/etc/php/8.x/cli/conf.d/* /etc/php/8.2/cli/conf.d/
COPY ./root-fs/etc/php/8.x/mods-available /etc/php/8.2/mods-available
COPY ./root-fs/etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf

FROM bluespice-prepare AS bluespice-final
ENV PATH="/app/bin:${PATH}"
RUN apt-get -y auto-remove \
	&& apt-get -y clean \
	&& apt-get -y autoclean \
	&& rm -Rf /usr/share/doc \
	&& find /var/log -type f -delete \
	&& rm -Rf /var/lib/apt/lists/* \
	&& rm -fr /tmp/*
WORKDIR /app
USER bluespice
EXPOSE 9090
ENTRYPOINT ["/app/bin/entrypoint"]
