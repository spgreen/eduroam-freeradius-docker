#!/bin/sh

ENV1="PRODUCTION"
ENV2="TEST"

#Changes the variables to the ones in the restart script
#FLR Server settings
sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g" -e "s/YOUR_REALM/$YOUR_REALM/g"  \
	/etc/raddb/clients.conf

#FLR Proxy Settings
sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g" \
	/etc/raddb/proxy.conf
sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" /etc/raddb/proxy.conf

sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" /etc/raddb/sites-enabled/eduroam

#Configures the test.sh script with the FLR IP addresses and the FLR secret via the restart script
sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g"  \
	/root/test.sh

#Sets up the testuser account via the restart script
sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" -e "s/TEST_PASSWORD/$TEST_PASSWORD/g" /etc/raddb/mods-config/files/authorize


#Configures the number of FLR Servers between 1 to 2. If 1 is selected in the restart script, the 2nd FLR Variables will be commented out
if [ "$NO_OF_FLR_SERVERS" = 1 ]; then
	sed -i -e '305,314 s/^/#/' /etc/raddb/clients.conf
	sed -i -e '13,18 s/^/#/' /etc/raddb/proxy.conf
        sed -i -e "s/\(home_server[\t ]*= FLR2\)/#&1/" /etc/raddb/proxy.conf
fi

#Configures the environment (TEST or PRODUCTION)
if [ "$ENVIRONMENT" = "$ENV1" ]; then
	exec radiusd -f
elif [ "$ENVIRONMENT" = "$ENV2" ]; then
	exec radiusd -X -l /dev/stdout -f
else
	echo ERROR
fi
