FROM alpine:3.20 AS base
ENV TZ=CET
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apk add \
	openssl \
	openrc \
	ca-certificates \
	imagemagick \
	texlive-dvi \
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
	poppler-utils \
	python3 \
	vim \
	rsvg-convert
FROM base AS bluespice-prepare
ENV PATH="/app/bin:${PATH}"
ARG UID
ENV UID=1002
ARG USER
ENV USER=bluespice
ARG GID
ENV GID=$UID
ARG GROUPNAME
ENV GROUPNAME=$USER

RUN addgroup -g $GID $GROUPNAME \
	&& adduser -u $UID -G $GROUPNAME --disabled-password --gecos "" $USER \
	&& addgroup $USER nginx \
	&& mkdir -p /app/bluespice \
	&& cd /app/bluespice \
	&& chmod -R 777 /var/log
COPY --chown=$USER:$GROUPNAME ./_codebase/bluespice /app/bluespice/w
COPY --chown=$USER:$GROUPNAME ./_codebase/simplesamlphp/ /app/simplesamlphp
COPY --chown=$USER:$GROUPNAME --chmod=755 ./root-fs/app/bin /app/bin
COPY --chown=$USER:$GROUPNAME ./root-fs/app/conf /app/conf
COPY --chown=$USER:$GROUPNAME ./root-fs/app/simplesamlphp /app/
ADD https://raw.githubusercontent.com/hallowelt/docker-bluespice-formula/main/_client/mathoid-remote /app/bin
ADD https://github.com/hallowelt/misc-mediawiki-adm/releases/latest/download/mediawiki-adm /app/bin
ADD https://github.com/hallowelt/misc-parallel-runjobs-service/releases/download/2.0.0/parallel-runjobs-service /app/bin
COPY ./root-fs/etc/php/8.x/fpm/php-fpm.conf /etc/php83
COPY ./root-fs/etc/php/8.x/fpm/pool.d/www.conf /etc/php83/php-fpm.d/
COPY ./root-fs/etc/php/8.x/cli/conf.d/* /etc/php83/conf.d/
COPY ./root-fs/etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
COPY ./root-fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf

FROM bluespice-prepare AS bluespice-final
WORKDIR /app
USER bluespice
EXPOSE 9090
#ENTRYPOINT ["sleep infinity"]
CMD ["sleep", "infinity"]