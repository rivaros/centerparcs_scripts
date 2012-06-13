
function check() {

    if [ `uname` == "Linux" ];then
        return 1
    fi

    if [ ! -f /opt/local/apache2/conf/httpd.conf -o ! -f /opt/local/apache2/conf/httpd.conf.macports ]; then
        if [[ $1 ]];then echo "ERROR: httpd.conf not replaced";else return 0;fi
    fi
    if [ ! -f /opt/local/apache2/conf/extra/httpd-vhosts.conf -o ! -f /opt/local/apache2/conf/extra/httpd-vhosts.conf.macports ]; then
        if [[ $1 ]];then echo "ERROR: httpd-vhosts.conf not replaced";else return 0;fi
    fi
    if [ ! -f /opt/local/etc/php5/php.ini ];then
        if [[ $1 ]];then echo "ERROR: php.ini missing";else return 0;fi
    fi    
    
    #Try to determine Apache user
    apacheuser=`ps -eo user,stat,args | grep httpd | grep -v grep | grep -v Ss | head -1 | awk '{print $1}'`
    if [ $apacheuser == "root" ];then
        if [[ $1 ]];then echo "ERROR: cannot grep apache user - grepped root";else return 0;fi
    elif [ $apacheuser == '' ];then
        if [[ $1 ]];then echo "ERROR: cannot grep apache user - grepped null";else return 0;fi
    fi
    
    if [[ $1 ]];then echo "Grepped Apache User: $apacheuser";fi
            
    return 1

}

function install() {

    #ENVITONMRNT Configuration /etc/hosts
    grep -l "mmp" /etc/hosts >/dev/null || echo "127.0.0.1   mmp" | tee -a /etc/hosts >/dev/null

    if [ `uname` == "Linux" ];then
        echo "You should install Apache manually on Linux"
    fi


    if [ `uname` == "Darwin" ];then
        #Apache
        if [ -f /opt/local/apache2/conf/httpd.conf -a ! -f /opt/local/apache2/conf/httpd.conf.macports ]; then
            cp -f /opt/local/apache2/conf/httpd.conf /opt/local/apache2/conf/httpd.conf.macports
        fi
        if [ -f /opt/local/apache2/conf/extra/httpd-vhosts.conf -a ! -f /opt/local/apache2/conf/extra/httpd-vhosts.conf.macports ]; then
            cp -f /opt/local/apache2/conf/extra/httpd-vhosts.conf /opt/local/apache2/conf/extra/httpd-vhosts.conf.macports
        fi
        mkdir -p /opt/local/apache2/conf/extra
        cp -f confs/apache/httpd.conf /opt/local/apache2/conf/httpd.conf
        cp -f confs/apache/httpd-vhosts.conf /opt/local/apache2/conf/extra/httpd-vhosts.conf
        if [ -f /opt/local/etc/php5/php.ini -a ! -f /opt/local/etc/php5/php.ini.macports ]; then
            cp -f /opt/local/etc/php5/php.ini /opt/local/etc/php5/php.ini.macports
        fi
        cp -f confs/php/php.ini /opt/local/etc/php5/php.ini
        killall httpd 2>/dev/null
        #/opt/local/apache2/bin/apachectl -k restart
        port load apache2
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
                    echo "ERRORS"
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




