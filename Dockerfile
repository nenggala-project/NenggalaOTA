ARG PHP_VERSION=7.4
FROM alpine:latest

ENV HTML_DIR /var/www/localhost/htdocs
ENV FULL_BUILDS_DIR $HTML_DIR/builds/full

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install system dependencies
RUN apk add --no-cache apache2 \
	php7 \
	php7-apache2 \
	php7-pecl-apcu \
	php7-mbstring \
	php7-intl \
	php7-json \
	php7-openssl \
	php7-phar \
	php7-zip \
	git \
	shadow \
	linux-pam && \
groupmod -g 1000 apache && usermod -u 1000 apache && \
apk del --no-cache shadow linux-pam && \
ln -s /dev/fd/1 /var/log/apache2/access.log && \
ln -s /dev/fd/2 /var/log/apache2/error.log && \
sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf && \
sed -i '/AllowOverride None/s/None/All/g' /etc/apache2/httpd.conf

RUN echo 'apc.ttl=7200' > /etc/php7/conf.d/opcache-recommended.ini

WORKDIR /var/www/localhost/htdocs

RUN rm index.html && composer create-project --no-cache julianxhokaxhiu/lineage-ota .

COPY .htaccess .

RUN chown -R apache:apache /var/www/localhost/htdocs

EXPOSE 80

VOLUME $FULL_BUILDS_DIR

CMD httpd -DFOREGROUND "$@"

