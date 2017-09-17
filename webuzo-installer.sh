hostip=`hostname -i`

if [ -f /etc/debian_version ]
  then
echo "reload yes
precedence ::ffff:0:0/96 100
precedence ::/0 10" >> /etc/gai.conf
#	apt-get update
#	apt-get -y upgrade
  	apt-get -y curl
	apt-get -y remove --purge apache2 apache2-bin apache2-data apache2-doc apache2-utils
  else
	yum -y update
  	yum -y install curl yum-cron
	yum remove -y httpd httpd-tools	
fi

wget -qO /etc/motd http://vpsrepo.a2hosting.com/semi/webuzoinstalling_motd

bash /root/installer.sh

curl -v 'https://my.a2hosting.com/index.php?m=a2_pseudoapis&api=a2-reset-webuzo&code=D5MZnRhX&dedicatedip='$hostip  >> /root/webuzo-install.log
curl -v 'http://dev-whmcs.a2hosting.com/index.php?m=a2_pseudoapis&api=a2-reset-webuzo&code=D5MZnRhX&dedicatedip='$hostip  >> /root/webuzo-install.log
endcheck=1
until [ $endcheck = 0 ]
 do
    sleep 2
    echo "Not Editable"
endcheck=`grep -c ip.php /usr/local/webuzo/enduser/universal.php`
 done
echo "Editable waiting for configurations to be completed."
sleep 300
sed -i "/sn/s|Webuzo|A2 Hosting Webuzo|" /usr/local/webuzo/enduser/universal.php
sed -i "/random_username/s|''|1|" /usr/local/webuzo/enduser/universal.php
sed -i "/random_pass/s|''|1|" /usr/local/webuzo/enduser/universal.php
sed -i "/random_dbprefix/s|''|1|" /usr/local/webuzo/enduser/universal.php
sed -i "/logo_url/s|false|'https://www.a2hosting.com/images/uploads/general/a2hosting-official-200x70-white.png'|" /usr/local/webuzo/enduser/universal.php
sed -i "/no_prefill/s|''|1|" /usr/local/webuzo/enduser/universal.php
sed -i "/default_cat_hover/s|''|'#7b7b7b'|"  /usr/local/webuzo/enduser/universal.php
sed -i "/demo_logo/s|''|'https://www.a2hosting.com/images/uploads/general/a2hosting-official-150x45.png'|" /usr/local/webuzo/enduser/universal.php
sed -i "/default_hf_bg/s|''|'#333333'|" /usr/local/webuzo/enduser/universal.php
#sed -i 's|<Directory|#<Directory|' /usr/local/apps/apache/etc/conf.d/webuzo*.conf
#sed -i 's|RMode stat|#RMode stat|' /usr/local/apps/apache/etc/conf.d/webuzo*.conf
#sed -i 's|RUidGid admin admin|#RUidGid admin admin|' /usr/local/apps/apache/etc/conf.d/webuzo*.conf
#sed -i 's|</Directory>|#</Directory|' /usr/local/apps/apache/etc/conf.d/webuzo*.conf
#service httpd restart
#service nginx restart

echo "File Edited"

sed -i '/webuzo.sh/d' /etc/rc.local
sed -i '/curl/d' /etc/rc.local
rm -f /root/webuzo.sh 
rm -f /root/webuzo-installer.sh

wget -qO /etc/motd http://vpsrepo.a2hosting.com/semi/webuzopost_motd
