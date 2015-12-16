#!/bin/sh

EDUROAM_FLR1=192.168.100.102
EDUROAM_FLR2=192.168.100.110
FLR_EDUROAM_SECRET=supertest
YOUR_REALM=docker.sg
TEST_PASSWORD=docker123

docker stop freeradius-eduroam; docker rm freeradius-eduroam
docker run -d --name freeradius-eduroam -v /etc/localtime:/etc/localtime:ro -p 1812:1812/udp -p 1813:1813/udp \
  -e EDUROAM_FLR1=$EDUROAM_FLR1 -e EDUROAM_FLR2=$EDUROAM_FLR2 -e FLR_EDUROAM_SECRET=$FLR_EDUROAM_SECRET \
  -e YOUR_REALM=$YOUR_REALM -e  TEST_PASSWORD=$TEST_PASSWORD \
  spgreen/freeradius-eduroam

