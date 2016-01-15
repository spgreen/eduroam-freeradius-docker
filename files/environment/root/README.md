test.sh README

test.sh is a shell script which uses eapol_test progmra from the wpa_supplicant package to authenticate an eduroam formatted username and password against the appropriate servers.

Running the script:

1. Enter the username, password and the number 1 or 2 after test.sh as follows:

    ># ./test.sh testuser@<yourdomain.tld> <password> <1 or 2>


    NOTE:   The number 1 after the password configures test.sh to send the request though your first eduroam FLR
            The number 2 will do the same but request will be sent to the second FLR instead

    Example:

    ># ./test.sh testuser@mydomain.sg test12345 1

        a. Username: testuser@mydomain.sg
        b. Password: test12345
        c. FLR Server: 1

2.  If the "SUCCESS" message appears, the user has successfully authenticated against their FreeRADIUS server.
    If the "FAILIURE" message appears, then the following issues could have occurred:

        a. Mistyped user credentials
        b. User does not exist
        c. FLR Server active but not configured correctly
        d. FLR Server offline       
