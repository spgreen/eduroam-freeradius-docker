#!/bin/sh

sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g" \
	/etc/raddb/clients.conf

sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g" \
	/etc/raddb/proxy.conf

sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" /etc/raddb/proxy.conf


#sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g" /root/test.sh
sed -i -e "s/EDUROAM_FLR1/$EDUROAM_FLR1/g" -e "s/EDUROAM_FLR2/$EDUROAM_FLR2/g" -e "s/FLR_EDUROAM_SECRET/$FLR_EDUROAM_SECRET/g"  \
	/root/test.sh

sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" /etc/raddb/sites-enabled/eduroam

sed -i -e "s/YOUR_REALM/$YOUR_REALM/g" -e "s/TEST_PASSWORD/$TEST_PASSWORD/g" /etc/raddb/mods-config/files/authorize



/usr/local/raddb/sbin/radiusd -xx -l /var/log/freeradius/radius.log -f
