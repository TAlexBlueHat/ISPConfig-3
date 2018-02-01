#---------------------------------------------------------------------
# Function: InstallWebServer Debian 8
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ $CFG_WEBSERVER == "apache" ]; then
  CFG_NGINX=n
  CFG_APACHE=y
  echo -n "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get install apt-transport-https lsb-release ca-certificates
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
	apt-get update
	apt-get -yqq install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libapache2-mod-php7.1 libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec libapache2-mod-passenger libapache2-mod-python libexpat1 ssl-cert libruby > /dev/null 2>&1  
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.1 php7.1-common php7.1 php7.1-common php7.1-dev php7.1-gd php7.1-mysqlnd php7.1-imap php7.1-cli php7.1-cgi php-pear php-auth php7.1-fpm php7.1-mcrypt php7.1-imagick php7.1-curl php7.1-intl php7.1-memcached php7.1-pspell php7.1-recode php7.1-snmp php7.1-sqlite php7.1-tidy php7.1-xmlrpc php7.1-xsl > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed Programs for PHP and Apache... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
    	echo -e "[${green}DONE${NC}]\n"	
  if [ $CFG_PHPMYADMIN == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
	
  if [ "$CFG_XCACHE" == "yes" ]; then
	echo -n "Installing XCache... "
	apt-get -yqq install php7.1-xcache > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
  fi
	
	echo -n "Activating Apache2 Modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	a2enmod fcgid > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq install python-certbot-apache -t jessie-backports
	certbot &
	echo -e "[${green}DONE${NC}]\n"
  
  else
	
  CFG_NGINX=y
  CFG_APACHE=n
	echo -n "Installing NGINX and Modules... "
	service apache2 stop
	update-rc.d -f apache2 remove
	apt-get -yqq install nginx > /dev/null 2>&1
	service nginx start 
	apt-get -yqq install php5-fpm php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached php-apc > /dev/null 2>&1
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php5/fpm/php.ini
	echo -n "Installing needed Programs for PHP and NGINX... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini
	service php5-fpm reload
	apt-get -yqq install fcgiwrap
  
  if [ $CFG_PHPMYADMIN == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
  
  	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq install certbot -t jessie-backports
	certbot &
	echo -e "[${green}DONE${NC}]\n"
  
  fi
  echo -e "[${green}DONE${NC}]\n"
}
