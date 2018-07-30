#!/bin/sh

USERNAME=$1
PASSWORD=$2
FLR_SELECT=$3


sed -e "s/USERNAME/$USERNAME/" -e "s/PASSWORD/$PASSWORD/" test.conf.template > test.conf

if [ -n "$YOUR_REALM" ] ; then
    # prefix the Operator_Name with NamespaceID value "1" (REALM) as per RFC5580
    EAPOL_EXTRA="-N126:s:1$YOUR_REALM"
else
    EAPOL_EXTRA=""
fi

if [ "$FLR_SELECT" = 1 ]; then
    RADIUS_SERVER=EDUROAM_FLR1
elif [ "$FLR_SELECT" = 2 ]; then
    RADIUS_SERVER=EDUROAM_FLR2
else
    RADIUS_SERVER=
fi

if [ -n "$RADIUS_SERVER" ] ; then
    eapol_test -c test.conf -a $RADIUS_SERVER -p 1812 -s FLR_EDUROAM_SECRET $EAPOL_EXTRA
else
    echo
    echo " Re-run the command using the following format:"
    echo " ./test.sh testuser@<yourdomain.tld> <password> <1 or 2>"
    echo " Where 1 & 2 represents the primary and secondary FLR servers to send the authentication request to."
    echo
fi

