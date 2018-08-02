## spgreen/eduroam-freeradius-docker

README Author: Simon Green


Docker image which allows the user to create a FreeRADIUS server with bare minimum eduroam presets within a Docker container.

Based off GÉANT's technical documentation found [here](https://wiki.geant.org/display/H2eduroam/How+to+deploy+eduroam+on-site+or+on+campus#Howtodeployeduroamon-siteoroncampus-FreeRADIUS).

Based off lrhazi's freeradius-eduroam docker setup found [here](https://github.com/lrhazi/freeradius-eduroam ).

##### Note:

* The following symbol "$" indicates code to be run inside the terminal 
* The following symbol ">#" indicates code to be run inside the terminal as a super user (sudo 'command', su, sudo -s)
* The hashtag symbols "#" are comment lines with useful information


##### Files have been edited to follow GÉANT's Technical documentation for eduroam Identity Providers (IdPs)

###### Configuration files that have been edited in /etc/raddb/:  

    proxy.conf
    clients.conf 
    radiusd.conf
    mods-config/files/authorize   #new location for /etc/raddb/users 
    mods-available/eap
    mods-config/attr_filter/pre-proxy
                                                            
###### Configuration files that have been created for eduroam:    
 
    sites-enabled/eduroam  
    sites-enabled/eduroam-inner-tunnel


###### You can view just the edited files in their appropriate directories here : 

    files/edited_raddb_config/
    
##### Script files: 

    build_eduroamFreeRADIUS.sh          # rebuilds freeradius-eduroam Docker image files. Edit configuration 
                                        # files first in /files/etc/raddb/* for your eduroam IdP configuration
                                        # before building the image
    
    restart_eduroamFreeRADIUS.sh        # starts/restarts the docker container. 
                                        # IMPORTANT: Add the necessary config for your eduroam IdP
    
    access_eduroamFreeRADIUS.sh         # enter into container and test out configuration. It is suggested to open two 
                                        # terminals to view /var/log/freeradius/radius.log for debugging and the 
                                        # other for testing accounts


#### Pre-Requisites: 

A machine running Docker:

* [Ubuntu Installation & Quickstart Guide](https://docs.docker.com/linux/)

* [Windows Installation & Quickstart Guide](https://docs.docker.com/windows/)

* [Mac Installation & Quickstart Guide](https://docs.docker.com/mac/)

* [Other OS Installation Guide](https://docs.docker.com/v1.8/installation/)
	
                   
                    


### Setting Up and Running your eduroam IdP FreeRADIUS Server:

#### Initial Setup:
    	
1) Pull the spgreen/freeradius-eduroam Docker image from docker hub:
	    
		># docker pull spgreen/freeradius-eduroam


2) Git clone the package to your system. Ensure git is installed on your system.
	
    	$ git clone https://github.com/spgreen/eduroam-freeradius-docker
	    
3) Enter into the cloned directory

		$ cd eduroam-freeradius-docker
		
#### Configuration:
    
4) Configure variables in restart_eduroamFreeRADIUS.sh then save and exit

    	#Edit the following varibles to provide the necessary configuration for your eduroam IdP 
    	#in restart_eduroamFreeRADIUS.sh:
        
        NO_OF_FLR_SERVERS=1             # Select number of FLR servers in your eduroam setup (between 1 to 2)    
    	EDUROAM_FLR1=192.168.100.102
    	EDUROAM_FLR2=192.168.100.110    # Can be left blank if only running one FLR 
    	FLR_EDUROAM_SECRET=supertest
    	YOUR_REALM=docker.sg
    	YOUR_PASSWORD=docker123
    	ENVIRONMENT=TEST                # Select from either TEST or PRODUCTION  
        TZ=UTC                          # Set timezone. e.g. Asia/Singapore, Pacific/Auckland, etc

**Note**:  It links with the `./files/environment/root/run.sh` script to:
* configure your eduroam FLR servers with their corresponding secrets and your eduroam realm settings (yourdomain.tld) in `/etc/raddb/proxy.conf`
* configure your eduroam FLR servers with their secrets in `/etc/raddb/clients.conf`
* configure the testuser's realm and password in `/etc/raddb/mods-config/files/authorize`
* configures between TEST or PRODUCTION environment. TEST gives more debug logging information found in `/var/log/freeradius/radius.log`


#### Running:

5) Run restart_eduroamFreeRADIUS.sh:

		># ./restart_eduroamFreeRADIUS.sh

6)  You will receive two errors if this is your first time starting the container as the freeradius-eduroam container currently does not exist. A hexadecimal output will be displayed if the container has started correctly
            
		> 14c1813807d1de325de56987a8765b61f8b9e94422748349ab48aaab9976ef79

Now your FreeRADIUS eduroam IdP Docker container is running in the background
        

#### Accessing the Container:
    
7) To access the container, run the access_eduroamFreeRADIUS.sh script:

		># ./access_eduroamFreeRADIUS.sh
        
        
#### Testing Authentication:

##### Docker testuser using test.sh:

8) Use the test.sh script whilst inside the container to simulate an authentication request using the eapol_test tool.
	
		># ./test.sh <USERNAME>@<REALM> <PASSWORD> [1-2]
		
	- **\<USERNAME\>** - Replace with `testuser` as that is the default user within this container.
	- **\<REALM\>** - Replace with the `YOUR_REALM` variable assigned in Step 4.
	- **\<PASSWORD\>** - Replace with the `YOUR_PASSWORD` variable assigned in Step 4.
	- **\[1-2\]** - Enter the number 1 or 2 the indicate which FLR you wish to send the request to.
		- **1** = `EDUROAM_FLR1`
		- **2** = `EDUROAM_FLR2`
           
 	Example `test.sh` command usage using default variables from Step 4 :
                
		># ./test.sh testuser@docker.sg docker123 1
    
    
Execute the command. You will then receive either of these two messages:

	"SUCCESS" - the user has successfully authenticated 
	
	"FAILURE" - the user has failed authentication. Possible issues:

        	a. Mistyped user credentials
        	b. User does not exist
        	c. FLR Server active but not configured correctly
        	d. FLR Server offline     

Note: test.sh is using eapol_test to test the eap authentication between the FLR and the Docker eduroam IdP. If you want to see a more in-depth view of the authentication process, view the DEBUG log using the following command outside of the container (**only for TEST environment**):
                   
	docker logs -f freeradius-eduroam
                        
The log will give you a good idea if something has gone wrong

##### Docker testuser using rad_eap_test:
	
There is another method of testing user authentication which uses rad_eap_test, a program based off of eapol_test.

To test out your testuser or other eduroam user account, you can use the following command:
			
	rad_eap_test -H EDUROAM_FLR1 -P 1812 -S FLR_EDUROAM_SECRET  -u testuser@YOUR_REALM -A anon@YOUR_REALM -p TEST_PASSWORD -m WPA-EAP -e PEAP
	
	
Output:

	access-accept; 1 - User authentication successful
	access-reject; 1 - User authentication failed
	
You can also use -v parameter to enable a more verbose out:

	access-accept; 0
	RADIUS message: code=2 (Access-Accept) identifier=9 length=225
	   Attribute 1 (User-Name) length=23
	      Value: 'testuser@YOUR_REALM'
	   Attribute 89 (Chargeable-User-Identity) length=42
	      Value: 'e1848d1dc6b57838780d69ba9cbbe15e09ed3deb'
	   Attribute 26 (Vendor-Specific) length=58
	      Value: 000001371134d65111b94247f2bd2c31f2e9b640398fcfb46269eac32f48af1f73319cafce9d84ba7247caebf9d45dcd2f51205bc3190c0d
	   Attribute 26 (Vendor-Specific) length=58
	      Value: 000001371034df9d04efa93857a08aeb260d302033ce7495b96800d7a1434c9ce52a2f6f03eb808061fe971b2c313230154cb40a2f402783
	   Attribute 79 (EAP-Message) length=6
	      Value: 03090004
	   Attribute 80 (Message-Authenticator) length=18
	      Value: ff7fab15831628c240517f9583a818a4

	
Below are the list of parameters that can be used with rad_eap_test

	# wrapper script around eapol_test from wpa_supplicant project
	# script generates configuration for eapol_test and runs it
	# eapol_test is program for testing RADIUS and their EAP methods authentication
	
	Parameters :
	-H <address> - Address of radius server
	-P <port> - Port of radius server
	-S <secret> - Secret for radius server communication
	-u <username> - Username (user@realm)
	-A <anonymous_id> - Anonymous identity (anonymous_user@realm)
	-p <password> - Password
	-t <timeout> - Timeout (default is 5 seconds)
	-m <method> - Method (WPA-EAP | IEEE8021X )
	-v - Verbose (prints decoded last Access-accept packet)
	-c - Prints all packets decoded
	-s <ssid> - SSID
	-e <method> - EAP method (PEAP | TLS | TTLS | LEAP)
	-M <mac_addr> - MAC address in xx:xx:xx:xx:xx:xx format
	-i <connect_info> - Connection info (in radius log: connect from <connect_info>)
	-d <directory> - status directory (unified identifier of packets)
	-k <user_key_file> - user certificate key file
	-l <user_key_file_password> - password for user certificate key file
	-j <user_cert_file> - user certificate file
	-a <ca_cert_file> - certificate of CA
	-2 <phase2 method> - Phase2 type (PAP,CHAP,MSCHAPV2)
	-N - Identify and do not delete temporary files
	-O <domain.edu.cctld> - Operator-Name value in domain name format
	-I <ip address> - explicitly specify NAS-IP-Address
	-C - request Chargeable-User-Identity


                  
##### Other Users within eduroam:

9) Follow the same process as in Step 8 but using a different username and password.
The username and password must belong to an account that exists within your country's eduroam network.
                       
If both tests succeed, then your eduroam IdP FreeRADIUS is working correctly.
        
               
#### Exiting from the Docker FreeRADIUS Container:
    
10) To exit out of the container, use the following command:
        
		># exit

Note: The container will still be running in the background
            
            
#### Manually Start/Stop your new FreeRADIUS eduroam IdP Container:
         
11) Stop:
	
		># docker stop freeradius-eduroam
        
12) Start:
   
   		># docker start freeradius-eduroam
            
            
            
___
            
### Adding Extra Configurations to your FreeRADIUS eduroam Container

1) Edit files in the following directory to customise your FreeRADIUS eduroam IdP Server:
        
		files/environment/etc/raddb/
  
- The original files can be found here:	

		files/etc.ORIGINAL/raddb/    

2) Save the edited file(s) and run the build_eduroamFreeRADIUS.sh to rebuild the FreeRADIUS Docker image with your newly added configurations.

		># ./build_eduroamFreeRADIUS.sh

3) Run  restart_eduroamFreeRADIUS.sh  to start the Docker container using your newly built Docker image.

		># ./restart_eduroamFreeRADIUS.sh


- **Note**: If the Docker container fails to start, the added configuration is not valid
	- You can check the error messages using `># docker logs freeradius-eduroam` when `ENVRIONMENT=TEST`.

4) You have now successfully added configuration to the eduroam FreeRADIUS Docker image.


##### Example
Let's say that you need to add a couple of Access Point configurations to clients.conf for your eduroam infrastructure. 

This process can be easily completed with the following steps:

1) Edit clients.conf found within files/environment/etc/raddb/clients.conf in the GitHub Package/cloned directory.

		$ vi files/environment/etc/raddb/clients.conf

2) Add the client definition at the bottom of the file and at least a line after the FLR2 client definition, otherwise the restart script may cause unnecessary commenting when running restart_eduroamFreeRADIUS.sh with NO_OF_FLR_SERVERS=1.

**IMPORTANT:** Place extra client definitions under the client FLR2 definition!

**EXTRA IMPORTANT: DO NOT** remove the client FLR2 definition even if you are only running one FLR!


	client FLR2 {
		ipaddr		= EDUROAM_FLR2
	        secret          = FLR_EDUROAM_SECRET
	        shortname       = FLR2
	        nas_type        = other
	    	virtual_server = eduroam
		}
		
	client <AP IP address> {
		secret = <somesecret>
		shortname = <descriptive name>
		nastype = other
		}

Save and exit. 

3) Run build_eduroamFreeRADIUS.sh to rebuild the FreeRADIUS Docker image with your newly added configurations.
	
		># ./build_eduroamFreeRADIUS.sh

4) Run  restart_eduroamFreeRADIUS.sh  to start the Docker container using your newly built Docker image.

		># ./restart_eduroamFreeRADIUS.sh

- **Note**: If the Docker container fails to start, the added configuration is not valid
	- You can check the error messages using `># docker logs freeradius-eduroam` when `ENVRIONMENT=TEST`.

___

### Connecting the eduroam-freeradius-docker to the Ancillary Tools created by Vlad Mencl, REANNZ

#### Running the container using Docker Compose   

You have earlier deployed the institutional radius server with Docker.

You can now re-deploy it to run with docker-compose and link into the metrics tools - so that radius logs get pushed into the metrics tools.

* Shut down the existing freeradius-docker container:

        docker stop freeradius-docker
        docker rm -v freeradius-docker

* Clone the eduroam-freeradius-docker repository and navigate into th AncillaryToolIntegration directory there:

        git clone https://github.com/spgreen/eduroam-freeradius-docker.git
        cd eduroam-freeradius-docker/AncillaryToolIntegration

* Customize ````freeradius-eduroam.env```` with the same parameters as what you've done earlier in ````eduroam-freeradius-docker-public/restart_eduroamFreeRADIUS.sh````
  * Hint: you can see the differences by opening an additional ssh session and running

          cd eduroam-freeradius-docker-public
          git diff

* Customize ````filebeat-radius.env```` - set:
  * ````LOGSTASH_HOST```` to the hostname of your metrics server - the same VM name, xeap-wsNN.aarnet.edu.au
  * ````RADIUS_SERVER_HOSTNAME```` to what hostname should the radius server logs be associated with.  You can again enter your VM name, xeap-wsNN.aarnet.edu.au

* And in ````global-env.env````, customize system-level ````TZ```` and ````LANG```` as preferred - or you can copy over global.env from admintool:

        cp ~/etcbd-public/admintoool/global-env.env .

  * Note: the timezone setting here will be used to interpret the timezone on the radius logs.

* Use Docker-compose to start the containers:

        docker-compose up -d

* Now check your radius server and the filebeat container are operating normally:

        docker-compose logs

* Check the monitoring tool is reporting your IRS as operational.

* Check the metrics tool to view usage data from your server.
