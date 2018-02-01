#---------------------------------------------------------------------
# Function: InstallBasePhp Debian 8
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  echo -n "Installing basic php modules for ispconfig..."
  apt-get -yqq install php7.1-cli php7.1-mysql php7.1-mcrypt mcrypt > /dev/null 2>&1
  echo -e "[${green}DONE${NC}]\n"
}
