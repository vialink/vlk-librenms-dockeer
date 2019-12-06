FROM vialink/vlk-ubuntu
ARG DEBIAN_FRONTEND=noninteractive

ENV LIBRENMS_DOMAIN=librenms.domain.com
ENV COMMUNITY_SNMP=public
ENV DB_USER=librenms
ENV DB_PASS=librenms

RUN apt-get update && \
    apt install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt install -y curl acl composer fping git graphviz imagemagick mariadb-client \
    mariadb-server mtr-tiny nginx-full nmap php7.2-cli php7.2-curl php7.2-fpm \
    php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-snmp php7.2-xml \
    php7.2-zip python-memcache python-mysqldb rrdtool snmp snmpd whois && \
    useradd librenms -d /opt/librenms -M -r && \
    usermod -a -G librenms www-data

WORKDIR /opt

RUN git clone https://github.com/librenms/librenms.git && \
    chown -R librenms:librenms /opt/librenms && \
    chmod 770 /opt/librenms

RUN setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ && \
    setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/ 

WORKDIR /opt/librenms

RUN su - librenms && \
    ./scripts/composer_wrapper.php install --no-dev && \
    exit 

COPY executesql.sql /opt/librenms/ && \
     snmp/snmpd.conf /etc/snmp/

RUN systemctl restart mysql && \
    mysql -uroot -p < executesql.sql 

RUN rm /etc/nginx/sites-enabled/default && \
    systemctl restart nginx && \    
    curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro && \ 
    chmod +x /usr/bin/distro && \
    systemctl restart snmpd && \
    cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms && \
    cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

COPY librenms/config.php /opt/librenms/

ENTRYPOINT [ "/bin/zsh" ]