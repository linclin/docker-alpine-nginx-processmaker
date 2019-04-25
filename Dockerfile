#安装文档 https://wiki.processmaker.com/3.3/Stack_N225
#sudo docker run -d --restart=always -h processmaker  --name=processmaker    -p 81:80   registry.cn-shenzhen.aliyuncs.com/dev-ops/processmaker
FROM alpine:3.8
ENV PROCESSMAKER_VERSION 3.3.8
ADD "processmaker-${PROCESSMAKER_VERSION}-community.tar.gz" /opt/
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update  \
    && apk add   bash curl curl-dev openldap-dev tzdata nginx ca-certificates php5-fpm php5-opcache php5-json php5-zlib php5-xml   php5-pdo php5-phar php5-openssl php5-pdo_mysql php5-mysqli php5-mysql php5-gd php5-iconv php5-mcrypt php5-ctype php5-cli php5-curl php5-soap php5-ldap php5-dom  freetds   \ 
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
    mkdir -p /var/log/php-fpm/  &&\
    mkdir -p /var/run/php-fpm/  &&\
    mkdir -p /var/log/nginx/ 
ADD files/nginx.conf /etc/nginx/nginx.conf
ADD files/processmaker.conf /etc/nginx/conf.d/default.conf 
ADD files/php-fpm.conf /etc/php5/php-fpm.conf

EXPOSE 80
VOLUME "/opt/processmaker/"
WORKDIR "/opt/processmaker/workflow/engine"

CMD ["/run.sh"] 