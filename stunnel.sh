
function check() {

    if [ `uname` == "Linux" ];then
        return 1
    fi

    if [ `uname` == "Darwin" ];then
        if [ ! -f /opt/local/etc/stunnel/stunnel.conf ];then
            if [[ $1 ]];then echo "ERROR:Stunnel configuration file not copied";else return 0;fi
        fi
        
        if [ ! -f /opt/local/etc/stunnel/mmplocation.pem ];then
            if [[ $1 ]];then echo "ERROR:Location certificate absent";else return 0;fi    
        fi  
        
        if [ ! -f /opt/local/etc/LaunchDaemons/org.macports.stunnel/org.macports.stunnel.plist ];then
            if [[ $1 ]];then echo "ERROR:Stunnel plist not present";else return 0;fi    
        fi 

        if [ ! -f /Library/LaunchDaemons/org.macports.stunnel.plist ];then
            if [[ $1 ]];then echo "ERROR:Stunnel plist symbolic link not present";else return 0;fi    
        fi
        
        if [ ! -f /opt/local/etc/LaunchDaemons/org.macports.stunnel/stunnel.wrapper ];then
            if [[ $1 ]];then echo "ERROR:Stunnel wrapper not present";else return 0;fi    
        fi
        
        if [ -z "`launchctl list | grep org.macports.stunnel`" ];then
            if [[ $1 ]];then echo "ERROR:org.macports.stunnel not loaded";else return 0;fi  
        fi
              
    fi           
    
    if [[ $1 ]];then echo "Stunnel check ended";fi
    return 1

}

function install() {

if [ `uname` == "Linux" ];then
    echo "You need to install Stunnel manually on Linux"
fi

if [ `uname` == "Darwin" ];then
    #Stunnel
    if [ -f /opt/local/etc/stunnel/stunnel.conf -a ! -f /opt/local/etc/stunnel/stunnel.conf.macports ]; then
        cp -f /opt/local/etc/stunnel/stunnel.conf /opt/local/etc/stunnel/stunnel.conf.macports
    fi
    mkdir -p /opt/local/etc/stunnel
    mkdir -p /opt/local/var/lib/stunnel/certificates
    mkdir -p /opt/local/etc/LaunchDaemons/org.macports.stunnel
    cp -f confs/stunnel/mmplocation.pem /opt/local/etc/stunnel/mmplocation.pem
    chown root:admin /opt/local/etc/stunnel/mmplocation.pem
    chmod 600 /opt/local/etc/stunnel/mmplocation.pem
    cp -f confs/stunnel/stunnel.conf /opt/local/etc/stunnel/stunnel.conf
    cp -R confs/stunnel/certificates /opt/local/var/lib/stunnel
    chown -R nobody:admin /opt/local/var/lib/stunnel
    cp -R LaunchDaemons/org.macports.stunnel /opt/local/etc/LaunchDaemons
    ln -fs /opt/local/etc/LaunchDaemons/org.macports.stunnel/org.macports.stunnel.plist /Library/LaunchDaemons/org.macports.stunnel.plist
    chmod 755 /opt/local/etc/LaunchDaemons/org.macports.stunnel/stunnel.wrapper
    port unload stunnel
    killall stunnel 2>/dev/null
    port load stunnel
fi


}


#Cross-platform Bucardo reanimate script v3.0
if [ ! -z "$1" ]; then
    while getopts "icd" opt; do
        case $opt in
            c)
                check
                if [[ $? == 1 ]];then
                    echo "OK"
                else
                    echo "ABSENT"
                fi
            ;;
            i)
                install
            ;;
            d)
                check diag
            ;;
            
        esac
    done
else
    echo "Running without parameters" >&2
fi




