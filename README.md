##spgreen/eduroam-freeradius-docker

README Author: Simon Green


Docker image which allows the user to create a FreeRADIUS server with bare minimum eduroam presets, within a Docker container.

Based off GÉANT's technical documentation found [here](https://wiki.geant.org/display/H2eduroam/How+to+deploy+eduroam+on-site+or+on+campus#Howtodeployeduroamon-siteoroncampus-FreeRADIUS).

Based off lrhazi's freeradius-eduroam docker setup found [here](https://github.com/lrhazi/freeradius-eduroam ).

####Note:

	The following symbol ">#" indicates code to be run inside the terminal as an admin user (sudo, su, sudo -s, etc)
	The hashtag symbols "#" are comment lines with useful information


####Files have been edited to follow GEANT's Technical documentation for eduroam IdPs

#####Configuration files that have been edited in /etc/raddb/:  

    proxy.conf
    clients.conf 
    radiusd.conf
    mods-config/files/authrorize   #links to /etc/raddb/users
    mods-available/eap
    mods-config/attr_filter/pre-proxy
                                                            
#####Configuration files that have been created for eduroam:    
 
    sites-enabled/eduroam  
    sites-enabled/eduroam-inner-tunnel


You can view just the edited files here in their appropriate directories here : 

    ./files/edited_raddb_config/
 

#####Three script files: 

    build_eduroamFreeRADIUS.sh          # rebuilds freeradius-eduroam Docker image files. Edit configuration 
		    							# files first in /files/etc/raddb/* for your eduroam IdP configuration
			    						# before building the image
    
    restart_eduroamFreeRADIUS.sh        # starts/restarts the docker container. 
    									# IMPORTANT: Add the necessary config for your eduroam IdP
    
    access_eduroamFreeRADIUS.sh         # enter into container and test out configuration. It is suggested to open two 
    									# terminals to view /var/log/freeradius/radius.log for debugging and the 
    									# other for testing accounts


####Pre-Requisites: 
	
    A machine running docker:
		a. Public address for production environment or,
		b. Private address of an internal testing cluster.                   

	
####Pre-Build:                    
                    
    If you need to edit and configure files to personalise you FreeRADIUS eduroam IdP server, please edit them here:   
        
		./files/etc/raddb/
  
    The original unedited files can be found here:

		./files/etc.ORIGINAL/raddb/                    

    If not, head to "Setting Up and Running your eduroam IdP FreeRADIUS Server" below                
                    

###Setting Up and Running your eduroam IdP FreeRADIUS Server:
    
    Build the Docker Image:

        1. Build the Docker image from the Dockerfile using the build_eduroamFreeRADIUS.sh script
        
        	># ./build_eduroamFreeRADIUS.sh 
        
        Once the process is completed successfully, head to the Configuration section below.
        
        
    Configuration:
    
        2. Configure variables in restart_eduroamFreeRADIUS.sh then save and exit

            #Edit the following varibles to provide the necessary configuration for your eduroam IdP 
		    #in restart_eduroamFreeRADIUS.sh:
            
            EDUROAM_FLR1=192.168.100.102
            EDUROAM_FLR2=192.168.100.110
            FLR_EDUROAM_SECRET=supertest
            YOUR_REALM=docker.sg
            YOUR_PASSWORD=docker123
            ENVIRONMENT=TEST #TEST or PRODUCTION  

        Notes:  It links with the './files/run.sh' script to:
					a. configure your eduroam FLR servers with their corresponding secrets and 
							your eduroam realm settings (yourdomain.tld) in /etc/raddb/proxy.conf
                	b. configure your eduroam FLR servers with their secrets in /etc/raddb/clients.conf
                	c. configure the testuser's realm and password in /etc/raddb/mods-config/files/authrorize 
							(links to /etc/raddb/users)
					d. configures between TEST or PRODUCTION environment. TEST gives more debug logging information
							found in /var/log/freeradius/radius.log
                              
    Running:

        3. Run restart_eduroamFreeRADIUS.sh:

               ># ./restart_eduroamFreeRADIUS.sh

        4.  You will get two errors if this is your first time starting since the freeradius-eduroam 
            container will not exist. You will receive a similar hexadecimal output if the container 
		    	has started correctly
            
                > 14c1813807d1de325de56987a8765b61f8b9e94422748349ab48aaab9976ef79

            Now your FreeRADIUS eduroam IdP Docker container is running in the background
        

    Accessing the Container:
    
        5. To access the container, run the access_eduroamFreeRADIUS.sh script:

            	># ./access_eduroamFreeRADIUS.sh
        
        
    Testing Authentication:
        
        Docker testuser:

        6. Use the test.sh script whilst inside the container with the username and password following the command. 
			e.g.
           
            The username for the test user is: testuser@YOUR_REALM 
                a. where YOUR_REALM is the variable that you assigned in Step 3.
           
            Password is: TEST_PASSWORD
                b. where TEST_PASSWORD is the variable that you assigned in Step 3
            
            After the password, enter the number 1 or 2 to indicate which FLR server you wish to send the request to.
            	1 = EDUROAM_FLR1
            	2 = EDUROAM_FLR2
           
            From the variables given in Step 3, the following test.sh command will be:
                
                ># ./test.sh testuser@docker.sg docker123 1
            
            Note: test.sh is using eapol_test to test the eap authentication between the FLR and the Docker eduroam IdP.
            	  If you want to see a more indepth view of the authentication process, view the log file located here:
                   
                        /var/log/freeradius/radius.log
                        
                  This will give you a good idea if something has gone wrong

                  
        Other Users within eduroam:

        7. Follow the same process as in Step 9 but using a different username and password. 
           The username and password must belong to an account that exists within your country's 
           eduroam network.
                       
           If both tests succeed, then your eduroam IdP FreeRADIUS is working correctly.
        
               
    Exiting from the Docker FreeRADIUS Container:
    
        8. To exit out of the container, use the following command:
        
            		># exit
            
            Note: The container will still be running in the background
            
            
    Manually Start/Stop your new FreeRADIUS eduroam IdP Container:
         
        9. Stop:
		        ># docker stop freeradius-eduroam
        
        10. Start:
       			># docker start freeradius-eduroam
            
        




    

    
   
