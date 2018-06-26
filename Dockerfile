FROM alpine:3.7

RUN apk update && apk upgrade 

#Installs necessary dependencies for compiling FreeRADIUS and other useful tools such as vim and tcpdump
RUN apk add freeradius freeradius-eap freeradius-ldap freeradius-krb5 tcpdump wpa_supplicant

RUN radiusd -v

#Compiles and installs the FreeRADIUS server from source and sets up the log file for TEST environment

#Copies the necessary configs to set up the FreeRADIUS Server for eduroam use
COPY files/environment/ /

EXPOSE 1812/udp 1813/udp
WORKDIR /root

CMD ["/root/run.sh"]
