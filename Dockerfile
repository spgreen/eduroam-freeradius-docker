FROM alpine:3.7
MAINTAINER Simon Green <simonpetergreen@singaren.net.sg>

ENV TZ UTC

RUN apk update && apk upgrade

#Installs necessary dependencies for compiling FreeRADIUS and other useful tools such as vim and tcpdump
RUN apk add freeradius freeradius-eap freeradius-ldap freeradius-krb5 \ 
            tcpdump wpa_supplicant bash grep bind-tools tzdata

#Copies the necessary configs to set up the FreeRADIUS Server for eduroam use
COPY files/environment/ /

EXPOSE 1812/udp 1813/udp
WORKDIR /root

CMD ["/root/run.sh"]
