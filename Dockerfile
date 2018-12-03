#安装文档 https://wiki.processmaker.com/3.3/Stack_N225
#sudo docker run -d --restart=always -h processmaker  --name=processmaker    -p 81:80   registry.cn-shenzhen.aliyuncs.com/dev-ops/processmaker
FROM alpine:3.8
ENV PROCESSMAKER_VERSION 3.3.0
ADD "processmaker-${PROCESSMAKER_VERSION}-community.tar.gz" /opt/
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update  \
    && apk add   bash curl curl-dev openldap-dev tzdata nginx ca-certificates php7-fpm php7-opcache php7-json php7-zlib php7-xml php7-mbstring php7-pdo php7-phar php7-openssl php7-pdo_mysql php7-mysqli php7-gd php7-iconv php7-mcrypt php7-ctype php7-cli php7-curl php7-soap php7-ldap php7-dom php7-mysql freetds   \ 
    && rm -rf /var/cache/apk/*  /tmp/*   /var/tmp/*  \
    && echo "Asia/Shanghai" > /etc/timezone  \
    && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  \
	&& chown -R nginx:www-data /opt/processmaker \
	&& cd /opt/processmaker/workflow/engine \
  	&& ln -s ../../gulliver/bin/gulliver gulliver \
	&& echo "*/5 * * * * php -f /opt/processmaker/workflow/engine/bin/cron.php +force" >> /var/spool/cron/crontabs/root

ADD files/run.sh /run.sh
RUN chmod +x /run.sh &&\
    mkdir -p /var/tmp/nginx/ /run/nginx &&\
    chown -R nginx:www-data /var/lib/nginx &&\
    sed -i '/short_open_tag = Off/c\short_open_tag = On' /etc/php.ini &&\
    sed -i '/post_max_size = 8M/c\post_max_size = 24M' /etc/php.ini &&\
    sed -i '/upload_max_filesize = 2M/c\upload_max_filesize = 24M' /etc/php.ini &&\
    sed -i '/;date.timezone =/c\date.timezone = America/New_York' /etc/php.ini &&\
    sed -i '/expose_php = On/c\expose_php = Off' /etc/php.ini &&\ 
    sed -i '/;opcache.enable_cli=0/c\opcache.enable_cli=1' /etc/php.d/opcache.ini &&\
    sed -i '/opcache.max_accelerated_files=4000/c\opcache.max_accelerated_files=10000' /etc/php.d/opcache.ini &&\
    sed -i '/;opcache.max_wasted_percentage=5/c\opcache.max_wasted_percentage=5' /etc/php.d/opcache.ini &&\
    sed -i '/;opcache.use_cwd=1/c\opcache.use_cwd=1' /etc/php.d/opcache.ini &&\
    sed -i '/;opcache.validate_timestamps=1/c\opcache.validate_timestamps=1' /etc/php.d/opcache.ini &&\
    sed -i '/;opcache.fast_shutdown=0/c\opcache.fast_shutdown=1' /etc/php.d/opcache.ini &&\
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/01-processmaker.conf /etc/nginx/conf.d/default.conf
ADD files/php /etc/nginx/php
ADD files/php-fpm.conf /etc/php5/php-fpm.conf

EXPOSE 80
VOLUME "/opt/processmaker/"
WORKDIR "/opt/processmaker/workflow/engine"

CMD ["/run.sh"] 