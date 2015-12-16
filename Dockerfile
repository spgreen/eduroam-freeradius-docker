FROM ubuntu:precise

RUN apt-get update && apt-get upgrade
RUN apt-get -y install \
    wget build-essential net-tools tcpdump lsb-base \
    libc6 libgdbm3 libltdl7 libpam0g libperl5.14 libpython2.7 \
    libssl1.0.0 ssl-cert ca-certificates adduser libmhash-dev libtalloc-dev \
    libperl-dev libssl-dev libpam-dev libgdb-dev libgdbm-dev  \
    software-properties-common vim

WORKDIR /opt
RUN wget ftp://ftp.freeradius.org/pub/freeradius/freeradius-server-3.0.10.tar.bz2
RUN tar xvf freeradius-server-3.0.10.tar.bz2

WORKDIR /opt/freeradius-server-3.0.10
RUN ./configure --prefix=/usr/local/raddb/ --sysconfdir=/etc; make; make install


ADD files/etc/raddb/ /etc/raddb/

RUN sed -i 's/allow_vulnerable_openssl.*/allow_vulnerable_openssl = CVE-2014-0160/g' \
    /etc/raddb/radiusd.conf # libssl1.0.1f ubuntu has had heartbleed fixed but naming scheme has not changed

ADD files/eapol/eapol_test /bin/eapol_test
ADD files/eapol/test.conf.template /root/test.conf.template
ADD files/eapol/test.sh /root/test.sh
ADD files/run.sh /root/run.sh

RUN mkdir -p /var/log/freeradius/
RUN touch /var/log/freeradius/radius.log



EXPOSE 1812/udp
EXPOSE 1813/udp
WORKDIR /root

CMD /root/run.sh
