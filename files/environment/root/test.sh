#!/bin/sh

USERNAME=$1
PASSWORD=$2
FLR_SELECT=$3


sed -e "s/USERNAME/$USERNAME/" -e "s/PASSWORD/$PASSWORD/" test.conf.template > test.conf

if [ "$FLR_SELECT" = 1 ]; then
    RADIUS_SERVER=EDUROAM_FLR1
elif [ "$FLR_SELECT" = 2 ]; then
    RADIUS_SERVER=EDUROAM_FLR2
else
    RADIUS_SERVER=
fi

if [ -n "$RADIUS_SERVER" ] ; then
    eapol_test -c test.conf -a $RADIUS_SERVER -p 1812 -s FLR_EDUROAM_SECRET
else
    echo
    echo " Re-run the command using the following format:"
    echo " ./test.sh testuser@<yourdomain.tld> <password> <1 or 2>"
    echo " Where 1 & 2 represents the primary and secondary FLR servers to send the authentication request to."
    echo
fi

