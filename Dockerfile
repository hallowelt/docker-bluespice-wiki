FROM debian:bullseye-slim AS base
ENV TZ=CET
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 && apt-get update  \
 && apt-get -y install --no-install-recommends gnupg2 curl wget ca-certificates apt-transport-https software-properties-common  \
 && apt-get update  

FROM base AS bluespice-main
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN apt-get update
RUN apt-get -y --no-install-recommends install \
	cron \
	openssl \
	imagemagick \
	dvipng \
	nginx \
	php8.0 \
	php8.0-fpm \
	vim \
	php8.0-xml \
	php8.0-mbstring \
	php8.0-curl \
	php8.0-zip \
	php8.0-cli \
	php8.0-mysql \
	php8.0-ldap \
	php8.0-opcache \
	php8.0-apcu \
	php8.0-intl \
	php8.0-gd \
	php8.0-gmp \
	poppler-utils \
	python3 \
	librsvg2-2 \
	librsvg2-bin \
	librsvg2-common \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

FROM bluespice-main AS bluespice-prepare
RUN mkdir -p /app/bluespice \
	&& cd /app/bluespice
COPY --chown=www-data:www-data ./_codebase/bluespice /app/bluespice/w
COPY ./root-fs/etc/nginx/sites-enabled/* /etc/nginx/sites-enabled
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./root-fs/app/bin /app/bin
COPY ./root-fs/app/conf /app/conf
ADD https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm /app/bin
ADD https://github.com/hallowelt/misc-parallel-runjobs-service/releases/download/1.0.0/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/conf.d/* /etc/php/8.0/fpm/conf.d
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php/8.0/fpm/
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php/8.0/fpm/pool.d/
COPY ./root-fs/etc/php/8.x/cli/conf.d/* /etc/php/8.0/cli/conf.d/
COPY ./root-fs/etc/php/8.x/mods-available /etc/php/8.0/mods-available

FROM bluespice-prepare AS bluespice-final
ENV PATH="/app/bin:${PATH}" 
RUN chmod 755 /app/bin/*
RUN mkdir -p /var/run/php 
RUN mkdir -p /app/bluespice/w/extensions/BlueSpiceFoundation/data/
RUN  apt-get -y auto-remove \
 && apt-get -y clean \
 && apt-get -y autoclean \
 && rm -Rf /usr/share/doc \
 && find /var/log -type f -delete \
 && rm -Rf /var/lib/apt/lists/* \
 && rm -fr /tmp/*
 ARG UID
 ARG GID
 ENV UID=1002
 ENV GID=1002
 RUN addgroup --gid $GID bluespice \
  && adduser --uid $UID --gid $GID --disabled-password --gecos "" bluespice \
  && usermod -aG www-data bluespice \
  && chown -R 1002:1002 /app/bin \
  && chown -R 1002:1002 /app/conf \
  && chown bluespice:www-data /var/run/php
WORKDIR /app
#USER bluespice
EXPOSE 9090
ENTRYPOINT ["/app/bin/entrypoint"]
