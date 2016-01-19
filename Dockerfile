FROM ubuntu:trusty

RUN apt-get update && apt-get -y upgrade 

#Installs necessary dependencies for compiling FreeRADIUS and other useful tools such as vim and tcpdump
RUN apt-get -y install \
    wget build-essential net-tools tcpdump lsb-base \
    libc6 libgdbm3 libltdl7 libpam0g libperl5.18 libpython2.7 \
    libssl1.0.0 ssl-cert ca-certificates adduser libmhash-dev libtalloc-dev \
    libperl-dev libssl-dev libpam-dev  \
    software-properties-common vim


#Compiles and installs the FreeRADIUS server from source and sets up the log file for TEST environment
RUN wget ftp://ftp.freeradius.org/pub/freeradius/freeradius-server-3.0.10.tar.bz2 -P /opt/ && \
        tar xvf /opt/freeradius-server-3.0.10.tar.bz2 -C /opt/ && \
        rm -f /opt/freeradius-server-3.0.10.tar.bz2 && \
    	    cd /opt/freeradius-server-3.0.10 && \
		./configure --prefix=/usr/local/raddb/ --sysconfdir=/etc && \
     		make && \
     		make install && \
                cd && \
                rm -rf /opt/freeradius-server-3.0.10 && \
    mkdir -p /var/log/freeradius/ && \
        touch /var/log/freeradius/radius.log 

#Copies the necessary configs to set up the FreeRADIUS Server for eduroam use
COPY files/environment/ /

RUN     sed -i 's/allow_vulnerable_openssl.*/allow_vulnerable_openssl = CVE-2014-0160/g' \
                /etc/raddb/radiusd.conf # libssl1.0.1f ubuntu has had heartbleed fixed but naming scheme has not changed


EXPOSE 1812/udp 1813/udp
WORKDIR /root

CMD ["/root/run.sh"]
