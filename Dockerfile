FROM debian:12-slim

# Common
RUN apt update \
	&& apt install -y --no-install-recommends \
	openssl \
	git \
	gnupg2 \
	vim \
	telnet \
	cron \
	tmux \
	mariadb-client \
	wget curl \
	htop

# Install Supervisor
RUN	apt install -y supervisor \
	&& mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/supervisor/conf.d/

# Install nginx
RUN apt install -y nginx \
	&& touch /run/nginx.pid

# Add Ondrej's repo source and signing key along with dependencies
RUN	apt install -y apt-transport-https lsb-release ca-certificates \
	&& wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

# Install php extension
RUN	apt update \
	&& apt install -y php8.3-common php8.3-cli php8.3-fpm php8.3-curl php8.3-bz2 php8.3-mbstring php8.3-intl \
	php8.3-apcu php8.3-opcache php8.3-pdo php8.3-tokenizer php8.3-iconv php8.3-calendar php8.3-ctype \
	php8.3-simplexml php8.3-bcmath php8.3-gd php8.3-zip php8.3-fileinfo php8.3-pdo-mysql php8.3-soap

# Add configuration
ADD www.conf /etc/php/8.3/fpm/pool.d/

ADD nginx.conf /etc/nginx/

ADD default.conf /etc/nginx/conf.d/

# Listing packages
RUN dpkg -l | grep php | tee packages.txt

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.7.0

# Copy source code
ADD ./src /var/www/html

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

# Add user
RUN groupadd -g ${PGID} app \
    && useradd -g ${PGID} -u ${PUID} -d /var/www -s /bin/bash app

RUN mkdir -p /var/www/html \
    && chown -R app:app /var/www /var/log /run/php/ \
    /var/lib/nginx /var/log/nginx /run/nginx.pid \
    /etc/supervisor/conf.d/

USER app:app
VOLUME /var/www
WORKDIR /var/www/html


CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]