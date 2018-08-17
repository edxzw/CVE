#!/bin/bash


################################################################################
# VARIABLES
################################################################################

##### Colors variables
_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)
_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_bold_blue=$(tput setaf 4)
_blue=$(tput setaf 38)
_white=$(tput setaf 7)
_bold_white=$_bold$(tput setaf 7)
_grey=$(tput setaf 8)
_message=$(tput setaf 29)
_info=$_underline$_bold$(tput setaf 39)
_result=$_underline$_bold$(tput setaf 82)

##### General variables
CURRENT_USER=$(echo $USER)
INSTALL_DIRECTORY=""
LOGFILE="/tmp/tomcat-install.log"

##### Tomcat variables
TOMCAT_BUILD_VERSION=""
TOMCAT_BUILD_RELEASE=""
TOMCAT_BUILD_PREFIX=""
TOMCAT_BUILD_SUFFIX=""
TOMCAT_BUILD_NAME=""
TOMCAT_BUILD_TYPE=""
TOMCAT_BUILD_URL=""

##### JDK variables
JDK_BUILD_VERSION=""
JDK_BUILD_RELEASE=""
JDK_BUILD_PREFIX=""
JDK_BUILD_SUFFIX=""
JDK_BUILD_NAME=""
JDK_BUILD_TYPE=""
JDK_BUILD_URL=""

#### Server variables
SERVER_PORT="8080"

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################

function _debug() {
    [ "$DEBUG" -eq 1 ] && $@
}

function _header() {
    printf "\n${_bold}${_purple}==========  %s  ==========${_reset}\n" "$@"
}

function _summary_header() {
    printf "\n${_bold}${_purple}#####################################################################################${_reset}\n"
    printf "\n${_bold}${_purple}#                                                                                   #${_reset}\n"
    printf "\n${_bold}${_purple}#${_reset}${_bold}${_red}  %s${_reset}${_bold}${_purple}                            #${_reset}\n"
    printf "\n${_bold}${_purple}#                                                                                   #${_reset}\n" 
}

function _summary_footer() {
    printf "\n${_bold}${_purple}#                                                                                   #${_reset}\n"
    printf "\n${_bold}${_purple}#####################################################################################${_reset}\n"
}

function _arrow() {
    printf "➜ $@\n"
}

function _success() {
    printf "${_green}✔ %s${_reset}: \n" "$@"
}

function _result() {
    printf "\n${_bold_white}[${_reset}${_bold}${_green}+${_reset}${_bold_white}] ${_reset}${_success}SUCCESS   ${_message}%s${_reset}: ${_reset}${_green}%s${_reset}\n" "$@"
}

function _info() {
    printf "${_bold_white}[${_reset}${_bold_blue}*${_reset}${_bold_white}] ${_reset}${_info}INFO   ${_message}%s${_reset}: ${_bold_blue}%s${_reset}\n" "$@"
}

function _error() {
    printf "${_red}✖ %s${_reset}\n" "$@"
}

function _warning() {
    printf "${_tan}➜ %s${_reset}\n" "$@"
}

function _underline() {
    printf "${_underline}${_bold}%s${_reset}\n" "$@"
}

function _bold() {
    printf "${_bold}%s${_reset}\n" "$@"
}

function _note() {
    printf "${_underline}${_bold_blue}Note:${_reset}  ${_blue}%s${_reset}\n" "$@"
}

function _die() {
    _error "$@"
    exit 1
}

function _safeExit() {
    exit 0
}



if [ "$1" != "" ] && [ "$2" != "" ]
then
    TOMCAT_BUILD_VERSION="$2"
    
    if [ "$1" == "bin" ] || [ "$1" == "binary"  ]
    then
        TOMCAT_BUILD_TYPE="bin"
        TOMCAT_BUILD_SUFFIX=""
        TOMCAT_BUILD_PREFIX="apache-tomcat-"
    else
        if [ "$1" == "deployer" ] || [ "$1" == "standalone" ]
        then
            TOMCAT_BUILD_TYPE="bin"
            TOMCAT_BUILD_SUFFIX="-deployer"
            TOMCAT_BUILD_PREFIX="apache-tomcat-"
        else
            if [ "$1" == "src" ] || [ "$1" == "source" ]
            then
                TOMCAT_BUILD_TYPE="src"
                TOMCAT_BUILD_SUFFIX="-src"
                TOMCAT_BUILD_PREFIX="apache-tomcat-"
            else
                if [ "$1" == "src" ] || [ "$1" == "source" ]
                then
                    TOMCAT_BUILD_TYPE="src"
                    TOMCAT_BUILD_SUFFIX=""
                    TOMCAT_BUILD_PREFIX="apache-tomcat-"

                else
                    _error "Wrong build type provided"
                    _safeExit
                fi
            fi
        fi
    fi

    TOMCAT_BUILD_NAME=$(echo "$TOMCAT_BUILD_PREFIX$TOMCAT_BUILD_VERSION$TOMCAT_BUILD_SUFFIX")
    TOMCAT_BUILD_RELEASE=$(echo "$TOMCAT_BUILD_VERSION" | grep -Po "^([0-9][^\.]*)")
    TOMCAT_BUILD_URL="http://mirror.switch.ch/mirror/apache/dist/tomcat/tomcat-$TOMCAT_BUILD_RELEASE/v$TOMCAT_BUILD_VERSION/$TOMCAT_BUILD_TYPE/$TOMCAT_BUILD_NAME.tar.gz"
    
    if [ "$3" != "" ]
    then
        INSTALL_DIRECTORY="$3"
    else
        INSTALL_DIRECTORY="/usr/local/$TOMCAT_BUILD_NAME"
    fi
    
    if [ -e "$INSTALL_DIRECTORY" ]
    then
        _warning "WARNING : $INSTALL_DIRECTORY Will Be Overwritten By New Installation"
         _arrow "[*] Are you sure that you want to install Tomcat $TOMCAT_BUILD_VERSION in : $INSTALL_DIRECTORY ? (y,n) : "
        read CONFIRM
        if [ "$CONFIRM" != "Y" ] && [ "$CONFRIM" != "y" ] && [ "$CONFIRM" != "yes" ]
        then
            _warning "Aborting ..."
            _safeExit
        fi
    fi
    _arrow "[*] Would you like to configure the server to use another port ? (default: $SERVER_PORT) : "
    read PORT
    if [ "$PORT" -le 65535 ] && [ "$PORT" -ge 1 ]
    then
          SERVER_PORT=$PORT
    fi
    _result "Using port: $SERVER_PORT"

    INSTALL_PARENT_DIRECTORY=$(dirname $INSTALL_DIRECTORY)
    
    if [ ! -e "$INSTALL_PARENT_DIRECTORY" ]
    then
        INSTALL_PARENT_DIRECTORY=$(dirname $INSTALL_PARENT_DIRECTORY)
    fi
        
    echo "###################################### Summary ######################################"
    echo ""
    echo "               Version: $TOMCAT_BUILD_VERSION     "
    echo "                 Build: $TOMCAT_BUILD_NAME        "
    echo "         Download From: $TOMCAT_BUILD_URL         "
    echo "        Install Prefix: $INSTALL_PARENT_DIRECTORY "   
    echo "     Install Directory: $INSTALL_DIRECTORY        "
    echo ""
    echo "#####################################################################################"
    _summary_footer
    
    
    _info "Setting temporary variables ..."
    JAVA_HOME=""
    CATALINA_HOME="$INSTALL_DIRECTORY"

    _info "Downloading Apache Tomcat $TOMCAT_BUILD_VERSION ..."
    wget $TOMCAT_BUILD_URL -O /tmp/$TOMCAT_BUILD_NAME.tar.gz 1>>$LOGFILE 2>>$LOGFILE
    
    _info "Extracting Files In : /tmp/$TOMCAT_BUILD_NAME ..."
    
    sudo tar -xf /tmp/$TOMCAT_BUILD_NAME.tar.gz -C $INSTALL_PARENT_DIRECTORY 1>>$LOGFILE 2>>$LOGFILE
    sudo chown $CURRENT_USER -R $INSTALL_DIRECTORY
    sudo rm -rf /tmp/$TOMCAT_BUILD_NAME.tar.gz
    
    _info "Getting Java installation directory ..."
    JAVA_HOME=$(readlink -f /etc/alternatives/java | sed "s/\/jre\/bin\/java//g")
    _result "Java installation" "$JAVA_HOME"
    
    _info "Getting JDK Version ..."
    JDK_VERSION=$($JAVA_HOME/jre/bin/java -version 2>&1 | head -n 1 |  grep -oP "\d+.\d[\d\.\_\-]*")
    _result "Java JDK" "$JDK_VERSION"
    
    _info "Adding \"JAVA_HOME\" environment variable entry into /etc/profile.d ..."
    echo -e "JAVA_HOME=$JAVA_HOME\nexport JAVA_HOME" > /tmp/java.sh
    sudo mv /tmp/java.sh /etc/profile.d/java.sh
    _result "Entry created" "/etc/profile.d/java.sh"

    _info "Adding \"CATLINA_HOME\" environment variable entry into /etc/profile.d ..."
    echo -e "CATLINA_HOME=$CATALINA_HOME\nexport CATALINA_HOME" > /tmp/catalina.sh
    sudo mv /tmp/catalina.sh /etc/profile.d/catalina.sh
    _result "Entry created" "/etc/profile.d/catalina.sh"
    
    _info "Moving to Catlina home directory: $CATALINA_HOME ..."
    cd $CATALINA_HOME/bin
    
    if [ "$TOMCAT_BUILD_TYPE" == "bin" ]
    then
        tar xvfz commons-daemon-native.tar.gz
        cd commons-daemon-*-native-src/unix
        
        _info "Building $PRODUCT daemon ..."
        
        ./configure --with-java="$JAVA_HOME"
        make
        cp jsvc $CATALINA_HOME/bin
        cd $CATALINA_HOME/bin ; ./jsvc -classpath $CATALINA_HOME/bin/bootstrap.jar:$CATALINA_HOME/bin/tomcat-juli.jar -outfile $CATALINA_BASE/logs/catalina.out -errfile $CATALINA_BASE/logs/catalina.err -Dcatalina.home=$CATALINA_HOME -Dcatalina.base=$CATALINA_BASE  -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties org.apache.catalina.startup.Bootstrap
        
    else
       if [ "$TOMCAT_BUILD_TYPE" == "src" ]
       then
          _info "Building $PRODUCT ..."
          cd $CATALINA_HOME
          ant 1>>$LOGFILE 2>>$LOGFILE
          _info "Replacing files with build output ..."
          sudo mv $INSTALL_DIRECTORY/output/build /tmp/$TOMCAT_BUILD_NAME
          sudo rm -rf $INSTALL_DIRECTORY/output/
          sudo cp -r /tmp/$TOMCAT_BUILD_NAME/* $INSTALL_DIRECTORY/
          sudo rm -rf /tmp/$TOMCAT_BUILD_NAME
       fi
    fi
    sudo chmod +x -R $INSTALL_DIRECTORY/
    sudo chown $USER -R $INSTALL_DIRECTORY/
    BUILD_INFO=$(sudo sh $INSTALL_DIRECTORY/bin/catalina.sh version | grep -vi "using")
    
    
    if [ "$BUILD_INFO" != "" ]
    then
        _result "Installation done" "$INSTALL_DIRECTORY/"
        echo ""
        echo "$BUILD_INFO"
    else
        _error "Installation Failed"
        echo ""
        echo " -> Please Check The Installation Log File : $LOGFILE"
    fi
else
    _header "Usage"
    echo "                                                                               "
    echo "  Arguments:"
    echo "        $0 <PACKAGE> <VERSION>"
    echo "        $0 <PACKAGE> <VERSION> [INSTALLATION_DIRECTORY]"
    echo "                                                                               "
    echo "  Example:"
    echo "         $0 bin 8.5.31 /opt/tomcat-8                                           "
    echo "         $0 bin 8.5.31 /usr/local/apache-tomcat-8.5.31                         "
    echo "                                                                               "
    echo "                                                                               "
   _header "Packages"
    echo "                                                                               "
    echo "  Packages available:                                                          "
    echo "                                                                               "
    echo "     base      : Base distribution                                             "
    echo "                 These distributions do not include wrappers/ compiled apr     "
    echo "                                                                               "
    echo "  deployer     : The standalone Tomcat Web Application Deployer.               "
    echo "                                                                               "
    echo "                                                                               "
    echo "    source     : Build from the source code.                                   "
    echo "                                                                               "
    echo "==============================================================================="
fi
