#!/bin/bash
echo "Checking Perl environment for missing modules"

#################################################################################
#
#  Check Perl modules and install if any are missing
#
################################################################################

echo -n "Checking boolean..."
perl -Mboolean -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install boolean"
else
    echo "OK"
fi

echo -n "Checking DBI..."
perl -MDBI -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    if [ `uname` == "Darwin" ];then
	port install p5.12-dbi
    else
	apt-get install libdbi-perl
    fi
else
    echo "OK"
fi

echo -n "Checking DBD::Pg..."
perl -MDBD::Pg -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    if [ `uname` == "Darwin" ];then
	port install p5.12-dbd-pg
    else
        apt-get install libdbd-pg-perl
    fi
else
    echo "OK"
fi

echo -n "Checking Test::Simple..."
perl -MTest::Simple -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    if [ `uname` == "Darwin" ];then
	port install p5.12-test-simple
    else
	apt-get install perl-modules
    fi
else
    echo "OK"
fi

echo -n "Checking DBIx::Safe..."
perl -MDBIx::Safe -e 1 > /dev/null 2>&1
if (( $? ))
then
    echo "Absent"
    echo "Installing..."
    if [ ! -d DBIx-Safe-1.2.5 ]; then
	    tar xvfz dbix_safe.tar.gz
    fi
    cd DBIx-Safe-1.2.5
    perl Makefile.PL
    make
    make install
    cd ..
else
    echo "OK"
fi

####################################################################################################
#
#         Create Bucardo installation folder, bucardo run folder, and try to install, if not already
#
###################################################################################################

if [ ! -d bucardo ]; then
    echo "Loading Bucardo...."
    git clone git://github.com/rivaros/bucardo.git
fi

if [ ! -d /var/run/bucardo ]; then
    mkdir /var/run/bucardo
fi

if [ -z "`bucardo show all | grep bucardo_current_version`" ]; then
	echo "Bucardo is not yet installed. We try."
	cd bucardo
	perl Makefile.PL
	make
	make install
	cd ..
	bucardo install 
	read -p "If previous operation failed press Ctr+C to exit script"
else
	echo "Bucardo seems to be installed already. If you want to reinstall, remove bucardo database."
fi

if [ `uname` == "Darwin" ]; then
        LOGROOT='/opt/local/var/log'
	BINROOT='/opt/local/bin'
elif [ `uname` == "Linux" ];then
        LOGROOT='/var/log'
	BINROOT='/usr/local/bin'
fi

#Bucardo general settings
bucardo set piddir=/var/run/bucardo
bucardo set log_conflict_file=$LOGROOT/bucardo_conflict.log
bucardo set reason_file=$LOGROOT/bucardo.restart.reason.log
bucardo set warning_file=$LOGROOT/bucardo.warning.log
#bucardo set log_level=terse
bucardo set default_email_from=bucardo@makemyphoto.nl
bucardo set default_email_to=r.ivantsiv@gmail.com

##########################################################################################################################
#
# Start Bucardo Configurator
#
##########################################################################################################################
. bucardo_configure.sh


########################################################################################################################
#
#  Install Bucardo reanimator
#
########################################################################################################################

#Bucardo checker
cp -f bucardo_reanimate.sh $BINROOT/bucardo_reanimate.sh
chmod 755 $BINROOT/bucardo_reanimate.sh

if [ `uname` == "Darwin" ];then
#On MacOS X bucardo will run under _www user
	grep -l "setenv PATH" /etc/launchd.conf >/dev/null || echo "setenv PATH $PATH" | tee -a /etc/launchd.conf >/dev/null
	launchctl setenv PATH $PATH
	cp -R LaunchDaemons/mmp.bucardo.check /opt/local/etc/LaunchDaemons
	ln -fs /opt/local/etc/LaunchDaemons/mmp.bucardo.check/mmp.bucardo.check.plist /Library/LaunchDaemons/mmp.bucardo.check.plist
	launchctl unload /Library/LaunchDaemons/mmp.bucardo.check.plist
	launchctl load /Library/LaunchDaemons/mmp.bucardo.check.plist

fi

if [ `uname` == "Linux" ];then
	read -p "Enter username, under which bucardo will run (should be webserver user):" bucardouser
	if [ -z "`grep "^${bucardouser}:" /etc/passwd`" ];then
		echo "Such user not found in the system"
		exit
	fi
	[ -n "`grep bucardo_reanimate.sh /etc/crontab`" ] \
	|| echo "*/5  *  *  *  *  root  $BINROOT/bucardo_reanimate.sh $bucardouser" >>/etc/crontab
	service cron restart
fi
	












