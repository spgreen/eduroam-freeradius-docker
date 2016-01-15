##spgreen/eduroam-freeradius-docker

README Author: Simon Green


Docker image which allows the user to create a FreeRADIUS server with bare minimum eduroam presets, within a Docker container.

Based off GÉANT's technical documentation found [here](https://wiki.geant.org/display/H2eduroam/How+to+deploy+eduroam+on-site+or+on+campus#Howtodeployeduroamon-siteoroncampus-FreeRADIUS).

Based off lrhazi's freeradius-eduroam docker setup found [here](https://github.com/lrhazi/freeradius-eduroam ).

#####Note:

* The following symbol "$" indicates code to be run inside the terminal 
* The following symbol ">#" indicates code to be run inside the terminal as a super user (sudo 'command', su, sudo -s)
* The hashtag symbols "#" are comment lines with useful information


#####Files have been edited to follow GÉANT's Technical documentation for eduroam Identity Providers (IdPs)

######Configuration files that have been edited in /etc/raddb/:  

    proxy.conf
    clients.conf 
    radiusd.conf
    mods-config/files/authrorize   #new location for /etc/raddb/users 
    mods-available/eap
    mods-config/attr_filter/pre-proxy
                                                            
######Configuration files that have been created for eduroam:    
 
    sites-enabled/eduroam  
    sites-enabled/eduroam-inner-tunnel


######You can view just the edited files in their appropriate directories here : 

    files/edited_raddb_config/
 

#####Script files: 

    build_eduroamFreeRADIUS.sh          # rebuilds freeradius-eduroam Docker image files. Edit configuration 
		    							# files first in /files/etc/raddb/* for your eduroam IdP configuration
			    						# before building the image
    
    restart_eduroamFreeRADIUS.sh        # starts/restarts the docker container. 
    									# IMPORTANT: Add the necessary config for your eduroam IdP
    
    access_eduroamFreeRADIUS.sh         # enter into container and test out configuration. It is suggested to open two 
    									# terminals to view /var/log/freeradius/radius.log for debugging and the 
    									# other for testing accounts


####Pre-Requisites: 

A machine running Docker:

* [Ubuntu Installation & Quickstart Guide](https://docs.docker.com/linux/)

* [Windows Installation & Quickstart Guide](https://docs.docker.com/windows/)

* [Mac Installation & Quickstart Guide](https://docs.docker.com/mac/)

* [Other OS Installation Guide](https://docs.docker.com/v1.8/installation/)
	
####Pre-Build Check:                    
                    
Edit files in the following directory during Step 4 to add extra features to your FreeRADIUS eduroam IdP Server:
        
		files/environment/etc/raddb/
  
The original files can be found here:	

		files/etc.ORIGINAL/raddb/                    

  

###Setting Up and Running your eduroam IdP FreeRADIUS Server:

####Initial Setup:
    	
1) Pull the spgreen/freeradius-eduroam Docker image from docker hub:
	    
		># docker pull spgreen/freeradius-eduroam


2) Git clone the package to your system. Ensure git is installed on your system.
	
    	$ git clone https://github.com/spgreen/eduroam-freeradius-docker
	    
3) Enter into the cloned directory

		$ cd eduroam-freeradius-docker
		
4) If you need to edit configuration files, do so now and then continue to Step 5 - "Build the Docker Image".

   Note: Tutorial for adding additional configurations can be found in "Adding Extra Configurations to your FreeRADIUS eduroam Container" section of this README. 
   
   Otherwise head to Step 6 - "Configuration"
    	

####Build the Docker Image:

5) Build the Docker image from the Dockerfile using the build_eduroamFreeRADIUS.sh script
        
		># ./build_eduroamFreeRADIUS.sh
        
Once the process is completed successfully, head to the Configuration section below.
        
        
####Configuration:
    
6) Configure variables in restart_eduroamFreeRADIUS.sh then save and exit

    	#Edit the following varibles to provide the necessary configuration for your eduroam IdP 
    	#in restart_eduroamFreeRADIUS.sh:
        
        NO_OF_FLR_SERVERS=1			#Select number of FLR servers in your eduroam setup (between 1 to 2)    
    	EDUROAM_FLR1=192.168.100.102
    	EDUROAM_FLR2=192.168.100.110		#If you only have 1 FLR Server, you can leave this variable blank
    	FLR_EDUROAM_SECRET=supertest
    	YOUR_REALM=docker.sg
    	YOUR_PASSWORD=docker123
    	ENVIRONMENT=TEST 			#Select from either TEST or PRODUCTION  

Notes:  It links with the './files/environment/root/run.sh' script to:
* configure your eduroam FLR servers with their corresponding secrets and your eduroam realm settings (yourdomain.tld) in /etc/raddb/proxy.conf
* configure your eduroam FLR servers with their secrets in /etc/raddb/clients.conf
* configure the testuser's realm and password in /etc/raddb/mods-config/files/authrorize 
* configures between TEST or PRODUCTION environment. TEST gives more debug logging information found in /var/log/freeradius/radius.log
                              
####Running:

7) Run restart_eduroamFreeRADIUS.sh:

		># ./restart_eduroamFreeRADIUS.sh

8)  You will get two errors if this is your first time starting since the freeradius-eduroam container will not exist. You will receive a similar hexadecimal output if the container has started correctly
            
		> 14c1813807d1de325de56987a8765b61f8b9e94422748349ab48aaab9976ef79

Now your FreeRADIUS eduroam IdP Docker container is running in the background
        

####Accessing the Container:
    
9) To access the container, run the access_eduroamFreeRADIUS.sh script:

		># ./access_eduroamFreeRADIUS.sh
        
        
####Testing Authentication:

#####Docker testuser:

10) Use the test.sh script whilst inside the container with the username and password following the command. e.g.
           
######Username for the test user:

		testuser@YOUR_REALM 

  where YOUR_REALM is the variable that you assigned in Step 3.  
  
             
             
######Password: 

		TEST_PASSWORD

where TEST_PASSWORD is the variable that you assigned in Step 3  


######FLR Server: 
Enter the number 1 or 2 to indicate which FLR server you wish to send the request to.

		1 = EDUROAM_FLR1
		2 = EDUROAM_FLR2
           
From the variables given in Step 3 and choosing EDUROAM_FLR1, the following test.sh command will be:
                
		># ./test.sh testuser@docker.sg docker123 1
    
    
Execute the command. You will then receive either of these two messages:

	"SUCCESS" - the user has successfully authenticated 
	
	"FAILIURE" - the user has failed authentication. Possible issues:

        	a. Mistyped user credentials
        	b. User does not exist
        	c. FLR Server active but not configured correctly
        	d. FLR Server offline     

Note: test.sh is using eapol_test to test the eap authentication between the FLR and the Docker eduroam IdP. If you want to see a more in-depth view of the authentication process, view the log file located here (**only in TEST environment**):
                   
	/var/log/freeradius/radius.log
                        
The log will give you a good idea if something has gone wrong

                  
#####Other Users within eduroam:

11) Follow the same process as in Step 9 but using a different username and password.
The username and password must belong to an account that exists within your country's eduroam network.
                       
If both tests succeed, then your eduroam IdP FreeRADIUS is working correctly.
        
               
####Exiting from the Docker FreeRADIUS Container:
    
12) To exit out of the container, use the following command:
        
		># exit

Note: The container will still be running in the background
            
            
####Manually Start/Stop your new FreeRADIUS eduroam IdP Container:
         
13) Stop:
	
		># docker stop freeradius-eduroam
        
14) Start:
   
   		># docker start freeradius-eduroam
            
            
            
___
            
###Adding Extra Configurations to your FreeRADIUS eduroam Container

Let's say that you need to add a couple of Access Point configurations to clients.conf for your eduroam infrastructure. 

This process can be easily completed with the following steps:

1) Edit clients.conf found within files/environment/etc/raddb/clients.conf in the GitHub Package/cloned directory.

	$ vi files/environment/etc/raddb/clients.conf

2) Add the client definition at the bottom of the file and at least a line after the FLR2 client definition. Otherwise the restart script may cause unnecessary commenting when running restart_eduroamFreeRADIUS.sh with NO_OF_FLR_SERVERS=1.

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

Note: If the Docker container does not start, the added configuration is not valid

	
        




    

    
   
