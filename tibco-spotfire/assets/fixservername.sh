#!/bin/bash

sleep 10

TSSDIR=/opt/tibco/tss/$VERSION/tomcat
TSSCONFIGFILE=$TSSDIR/spotfire-bin/TestConfig.xml

# Check that bootstrap does not exist
if test ! -f $TSSDIR/webapps/spotfire/WEB-INF/bootstrap.xml
then

	pushd $TSSDIR/bin
	./catalina.sh stop
	popd
	pushd $TSSDIR/spotfire-bin

	if [[ -z "$TSSNAME" ]]
	then
		TSSNAME=`hostname -I`
	fi
	
	echo TSSNAME=$TSSNAME
	echo Creating the database connection configuration bootstrap
	./config.sh bootstrap --no-prompt --driver-class=$DB_DRIVER --database-url=$DB_URL --username=$SERVERDB_USER --password=$SERVERDB_PASSWORD --tool-password=$CONFIG_TOOL_PASSWORD --server-alias=$TSSNAME -A$TSSNAME
	echo Checking configuration
	# Check to see if a configuration already exists or not
	./config.sh export-config --tool-password="$CONFIG_TOOL_PASSWORD" $TSSCONFIGFILE
	
	if test ! -f $TSSCONFIGFILE
	then
	    # Need to create configuration

		############# START CONFIGURATION SECTION

		# ## TODO: MAKE SURE TO UPDATE ANY PATHS TO MATCH THE INSTALLDIR INSTALLATION PATH

		# ######## NOTE These steps only need to be done one time when doing initial configuration
		# # update configuration - this step ONLY needs to be done once and not repeatedly, except for bootstrap creation
		# # DO SIMPLE Configuration 
		echo Creating the default configuration
		./config.sh create-default-config --force $TSSCONFIGFILE
		
		echo Importing the configuration
		./config.sh import-config --tool-password="$CONFIG_TOOL_PASSWORD" --comment="Initial Configuration" $TSSCONFIGFILE

		# Update deployment
		echo Deploying base Spotfire
		./config.sh update-deployment --bootstrap-config $TSSDIR/webapps/spotfire/WEB-INF/bootstrap.xml --tool-password="$CONFIG_TOOL_PASSWORD" --area Production /Spotfire.Dxp.sdn

		# Deploy TERR as a service deployment
		if [ "$DEPLOY_TERR" = "true" ] 
		then
			echo Deploying TERR packages
			./config.sh update-deployment --bootstrap-config $TSSDIR/webapps/spotfire/WEB-INF/bootstrap.xml --tool-password="$CONFIG_TOOL_PASSWORD" --area Production /Spotfire.Dxp.TerrServiceWindows.sdn 
		fi
		# Set auto trust - SET_AUTO_TRUST default is true 
		if [ "$SET_AUTO_TRUST" != "false"  ]
		then
			./config.sh set-config-prop --configuration=$TSSCONFIGFILE --name=security.trust.auto-trust.enabled --value=true
			echo Importing the configuration with auto trust enabled
			./config.sh import-config --tool-password="$CONFIG_TOOL_PASSWORD" --comment="Enabling Auto Trust" $TSSCONFIGFILE
		fi
		
		echo Creating the $ADMIN_USER user to become administrator
		./config.sh create-user --tool-password="$CONFIG_TOOL_PASSWORD" --username="$ADMIN_USER" --password="$ADMIN_PASSWORD"
		echo

		echo Promoting the user $ADMIN_USER to administrator
		./config.sh promote-admin --tool-password="$CONFIG_TOOL_PASSWORD" --username="$ADMIN_USER"
		echo
		############# END CONFIGURATION SECTION
	fi 

	popd
	# Remove configuration file - either created now or created when testing configuration
	rm -f %TSSCONFIGFILE%
fi

# Need to start server when machine starts up
pushd $TSSDIR/bin
./catalina.sh start
popd
