#!/bin/bash
clear

# Setenforce to 0
setenforce 0 >> /dev/null 2>&1

# Flush the IP Tables
iptables -F >> /dev/null 2>&1
iptables -P INPUT ACCEPT >> /dev/null 2>&1

SOFTACULOUS_FILREPO=http://www.softaculous.com
VIRTUALIZOR_FILEREPO=http://files.virtualizor.com
FILEREPO=http://files.webuzo.com
LOG=/root/webuzo-install.log
SOFT_CONTACT_FILE=/var/webuzo/users/soft/contact
EMPS=/usr/local/emps
CONF=/usr/local/webuzo/conf/webuzo


#----------------------------------
# Detecting the Architecture
#----------------------------------
if [ `uname -i` == x86_64 ]; then
	ARCH=64
else
	ARCH=32
	echo "--------------------------------------------------------"
	echo " Webuzo is not supported on 32 bit systems"
	echo "--------------------------------------------------------"
	echo "Exiting installer"
	exit 1;
fi

echo "--------------------------------------------------------"
echo " Welcome to Webuzo Installer"
echo "--------------------------------------------------------"
echo " Installation Logs : tail -f /root/webuzo-install.log"
echo "--------------------------------------------------------"
echo " "

#----------------------------------
# Some checks before we proceed
#----------------------------------

# Gets Distro type.

if [ -f /etc/debian_version ]; then
	OS=Ubuntu
	REL=$(cat /etc/issue)
elif [ -f /etc/redhat-release ]; then
	OS=redhat 
	REL=$(cat /etc/redhat-release)
else
	OS=$(uname -s)
	REL=$(uname -r)
fi

theos="$(echo $REL | egrep -i '(cent|Scie|Red|Ubuntu)' )"

if [ "$?" -ne "0" ]; then
	echo "Webuzo can be installed only on CentOS, Redhat, Ubuntu OR Scientific Linux"
	echo "Exiting installer"
	exit 1;
fi

# Is Virtualizor installed ?
if [ -d /usr/local/virtualizor ]; then
	echo "Webuzo conflicts with Virtualizor."
	echo "Exiting installer"
	exit 1;
fi

#----------------------------------
# Enabling Webuzo repo
#----------------------------------
if [ "$OS" = redhat ] ; then

	# Is yum there ?
	if ! [ -f /usr/bin/yum ] ; then
		echo "YUM wasnt found on the system. Please install YUM !"
		echo "Exiting installer"
		exit 1;
	fi

	# Download Webuzo repo
	wget http://mirror.softaculous.com/webuzo/webuzo.repo -O /etc/yum.repos.d/webuzo.repo >> $LOG 2>&1
	
elif [ "$OS" = Ubuntu ]; then

	version=$(lsb_release -r | awk '{ print $2 }')
	current_version=$( echo "$version" | cut -d. -f1 )

	if [ "$current_version" -eq "15" ]; then
		echo "Webuzo is not supported on Ubuntu 15 !"
		echo "Exiting installer"
		exit 1;
	fi
	
	# Is apt-get there ?
	if ! [ -f /usr/bin/apt-get ] ; then
		echo "APT-GET was not found on the system. Please install APT-GET !"
		echo "Exiting installer"
		exit 1;
	fi
	
fi


user="soft"
if [ "$OS" = redhat  ] ; then
	adduser $user >> $LOG 2>&1
	chmod 755 /home/soft >> $LOG 2>&1

	/bin/ln -s /sbin/chkconfig /usr/sbin/chkconfig >> $LOG 2>&1
else
	adduser --disabled-password --gecos "" $user >> $LOG 2>&1 
fi

#----------------------------------
# Install  Libraries and Dependencies
#----------------------------------
echo "1) Installing Libraries and Dependencies"

if [ "$OS" = redhat  ] ; then
	yum -y install gcc gcc-c++ unzip apr make vixie-cron sendmail >> $LOG 2>&1
else
	apt-get update -y >> $LOG 2>&1
	apt-get install -y gcc g++ unzip make cron sendmail >> $LOG 2>&1
	export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install iptables-persistent >> $LOG 2>&1
fi

#----------------------------------
# Setting UP WEBUZO
#----------------------------------
echo "2) Setting UP WEBUZO"

# Stop all the services of EMPS if they were there.
/usr/local/emps/bin/mysqlctl stop >> $LOG 2>&1
/usr/local/emps/bin/nginxctl stop >> $LOG 2>&1
/usr/local/emps/bin/fpmctl stop >> $LOG 2>&1


#-------------------------------------
# Remove the EMPS package
rm -rf $EMPS >> $LOG 2>&1

# The necessary folders
mkdir $EMPS >> $LOG 2>&1

echo "2) Setting Up WEBUZO" >> $LOG 2>&1
wget -N -O $EMPS/EMPS.tar.gz "http://files.softaculous.com/emps.php?arch=$ARCH" >> $LOG 2>&1

# Extract EMPS
tar -xvzf $EMPS/EMPS.tar.gz -C /usr/local/emps >> $LOG 2>&1
rm -rf $EMPS/EMPS.tar.gz >> $LOG 2>&1

#----------------------------------
# Download and Install Webuzo
#----------------------------------
echo "3) Downloading and Installing Webuzo"
echo "3) Downloading and Installing Webuzo" >> $LOG 2>&1

# Create the folder
rm -rf /usr/local/webuzo
mkdir /usr/local/webuzo >> $LOG 2>&1

# Get our installer
wget -O /usr/local/webuzo/install.php $FILEREPO/install.inc >> $LOG 2>&1

echo "4) Downloading System Apps"
echo "4) Downloading System Apps" >> $LOG 2>&1

# Run our installer
/usr/local/emps/bin/php -d zend_extension=/usr/local/emps/lib/php/ioncube_loader_lin_5.3.so /usr/local/webuzo/install.php $*
phpret=$?
rm -rf /usr/local/webuzo/install.php >> $LOG 2>&1
rm -rf /usr/local/webuzo/upgrade.php >> $LOG 2>&1

# Was there an error
if ! [ $phpret == "8" ]; then
	echo " "
	echo "ERROR :"
	echo "There was an error while installing Webuzo"
	echo "Please check $LOG for errors"
	echo "Exiting Installer"	
 	exit 1;
fi

# Get our initial setup tool
wget -O /usr/local/webuzo/enduser/webuzo/install.php $FILEREPO/initial.inc >> $LOG 2>&1

# Disable selinux
if [ -f /etc/selinux/config ] ; then 
	mv /etc/selinux/config /etc/selinux/config_  
	echo "SELINUX=disabled" >> /etc/selinux/config 
	echo "SELINUXTYPE=targeted" >> /etc/selinux/config 
	echo "SETLOCALDEFS=0" >> /etc/selinux/config 
fi

#----------------------------------
# Starting Webuzo Services
#----------------------------------
echo "Starting Webuzo Services" >> $LOG 2>&1
/etc/init.d/webuzo restart >> $LOG 2>&1

wget -O /usr/local/webuzo/enduser/universal.php $FILEREPO/universal.inc >> $LOG 2>&1

#-------------------------------------------
# FLUSH and SAVE IPTABLES / Start the CRON
#-------------------------------------------
service crond restart >> $LOG 2>&1

/sbin/iptables -F >> $LOG 2>&1

if [ "$OS" = redhat  ] ; then
	# Distro check for CentOS 7
	if [ -f /usr/bin/systemctl ] ; then
		/usr/libexec/iptables/iptables.init save >> $LOG 2>&1
	else
		/etc/init.d/iptables save >> $LOG 2>&1
	fi
	
	/usr/sbin/chkconfig crond on >> $LOG 2>&1
	
elif [ "$OS" = Ubuntu ]; then
	iptables-save > /etc/iptables.rules >> $LOG 2>&1
	update-rc.d cron defaults >> $LOG 2>&1
	/bin/ln -s /usr/lib/python2.7/plat-x86_64-linux-gnu/_sysconfigdata_nd.py /usr/lib/python2.7/
fi

#----------------------------------
# GET the IP
#----------------------------------
wget $FILEREPO/ip.php >> $LOG 2>&1 
ip=$(cat ip.php) 

echo " "
echo "-------------------------------------"
echo " Installation Completed "
echo "-------------------------------------"
echo "Congratulations, Webuzo has been successfully installed"
echo " "
echo "You can now configure Softaculous Webuzo at the following URL :"
echo "http://$ip:2004/"
echo " "
echo "Thank you for choosing Webuzo !"
echo " "
