#!/bin/sh

NO_OF_FLR_SERVERS=2 #Select the number of FLR servers that your eduroam setup uses. Select either 1 or 2
EDUROAM_FLR1=192.168.100.102
EDUROAM_FLR2=192.168.100.110
FLR_EDUROAM_SECRET=supertest
YOUR_REALM=docker.sg
TEST_PASSWORD=docker123
ENVIRONMENT=TEST #TEST or PRODUCTION





if [ $NO_OF_FLR_SERVERS = 1 ] || [ $NO_OF_FLR_SERVERS = 2 ]; then
	if [  $ENVIRONMENT = "TEST" ] || [  $ENVIRONMENT = "PRODUCTION" ]; then 
 
		docker stop freeradius-eduroam; docker rm freeradius-eduroam
		docker run -d --name freeradius-eduroam -v /etc/localtime:/etc/localtime:ro -p 1812:1812/udp -p 1813:1813/udp \
  			-e EDUROAM_FLR1=$EDUROAM_FLR1 -e EDUROAM_FLR2=$EDUROAM_FLR2 -e FLR_EDUROAM_SECRET=$FLR_EDUROAM_SECRET \
  			-e YOUR_REALM=$YOUR_REALM -e  TEST_PASSWORD=$TEST_PASSWORD -e ENVIRONMENT=$ENVIRONMENT -e NO_OF_FLR_SERVERS=$NO_OF_FLR_SERVERS \
  			spgreen/freeradius-eduroam
	else
		echo
		echo "Please enter either 'TEST' or 'PRODUCTION' for the ENVIRONMENT variable"
		echo "TEST environment produces debug logs found in /var/log/freeradius/radius.log"
		echo
	fi
else
	echo
	echo "Please enter either '1' or '2' for the NO_OF_FLR_SERVERS variable"
	echo "This will set the number of FLR servers you have within your eduroam setup"
	echo
fi
