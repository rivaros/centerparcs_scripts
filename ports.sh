
function check_ports() {

    if [ `uname` == "Linux" ];then
        return 1
    fi
    
    if [[ `uname` == *CYGWIN* ]];then
        if [ $1 ];then echo "You are on Cygwin. This option applies only to MacOS";fi
        return 1		
	fi

    if [ -z "`port installed perl5.12 2>/dev/null | grep \"perl5.12\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: perl5.12 not installed";else return 0;fi
    fi
    if [ -z "`port installed p5.12-dbi 2>/dev/null | grep \"p5.12-dbi\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: p5.12-dbi not installed";else return 0;fi
    fi
    if [ -z "`port installed p5.12-dbd-pg 2>/dev/null | grep \"p5.12-dbd-pg\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: p5.12-dbd-pg not installed";else return 0;fi
    fi
    if [ -z "`port installed apache2 2>/dev/null | grep \"apache2\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: apache2 not installed";else return 0;fi
    fi
    if [ -z "`port installed git-core 2>/dev/null | grep \"git-core\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: git-core not installed";else return 0;fi
    fi
    if [ -z "`port installed php5 2>/dev/null | grep \"php5\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5 not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-imagick 2>/dev/null | grep \"php5-imagick\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-imagick not installed";else return 0;fi
    fi    
    if [ -z "`port installed postgresql91 2>/dev/null | grep \"postgresql91\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: postgresql91 not installed";else return 0;fi
    fi    
    if [ -z "`port installed postgresql91-server 2>/dev/null | grep \"postgresql91-server\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: postgresql91-server not installed";else return 0;fi
    fi    
    if [ -z "`port installed php5-apc 2>/dev/null | grep \"php5-apc\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-apc not installed";else return 0;fi
    fi    
    if [ -z "`port installed php5-curl 2>/dev/null | grep \"php5-curl\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-curl not installed";else return 0;fi
    fi    
    if [ -z "`port installed php5-exif 2>/dev/null | grep \"php5-exif\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-exif not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-iconv 2>/dev/null | grep \"php5-iconv\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-iconv not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-intl 2>/dev/null | grep \"php5-intl\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-intl not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-mbstring 2>/dev/null | grep \"php5-mbstring\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-mbstring not installed";else return 0;fi        
    fi
    if [ -z "`port installed php5-posix 2>/dev/null | grep \"php5-posix\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-posix not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-sqlite 2>/dev/null | grep \"php5-sqlite\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-sqlite not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-postgresql 2>/dev/null | grep \"php5-postgresql\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-postgresql not installed";else return 0;fi
    fi
    if [ -z "`port installed php5-soap 2>/dev/null | grep \"php5-soap\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: php5-soap not installed";else return 0;fi
    fi
    if [ -z "`port installed rsync 2>/dev/null | grep \"rsync\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: rsync not installed";else return 0;fi
    fi
    if [ -z "`port installed screen 2>/dev/null | grep \"screen\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: screen not installed";else return 0;fi
    fi
    if [ -z "`port installed mc 2>/dev/null | grep \"mc\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: mc not installed";else return 0;fi
    fi
    if [ -z "`port installed stunnel 2>/dev/null | grep \"stunnel\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: stunnel not installed";else return 0;fi
    fi
    if [ -z "`port installed exiv2 2>/dev/null | grep \"exiv2\" | grep \"active\"`" ];then
        if [ $1 ];then echo -e "\n\tError: exiv2 not installed";else return 0;fi
    fi
    
    if [ $1 ];then echo -e "Finished port check";fi    
    return 1
}

function install_ports() {
    if [ `uname` == "Darwin" ];then
        xcode-select -switch /Applications/XCode.app/Contents/Developer 
        type -p -a port >/dev/null || exit "MacPorts not installed"
        port install perl5.12 +shared
        port install p5.12-dbi
        port install p5.12-dbd-pg
        port install apache2
        port install git-core
        port install php5 @5.3.12 +apache2
        port install php5-imagick
        port install postgresql91 +perl
        port install postgresql91-server
        port install php5-apc php5-curl php5-exif php5-iconv php5-intl php5-mbstring php5-posix php5-sqlite php5-postgresql
	port install php5-soap
        port install rsync screen mc
        port install stunnel
        port install exiv2
    elif [ `uname` == "Linux" ];then
        echo "You are on Linux. We assume you have all software prerequisites installed"
        read -p "Press any key to continue..."
    fi
    
    
    #ENVIRONMENT variables set
    export EDITOR=nano
    export PGDATABASE=mmp
    export PGUSER=postgres

    if [ `uname` == "Darwin" ];then
        export PATH=/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin:$PATH
        alias mc=". /opt/local/libexec/mc/mc-wrapper.sh"
    elif [ `uname` == "Linux" ];then
        alias mc=". /usr/share/mc/bin/mc-wrapper.sh"
    fi

    if [ `uname` == "Darwin" ];then
    #ENVIRONMENT Configuration /etc/profile
        grep -l "export EDITOR=" /etc/profile >/dev/null || echo "export EDITOR=nano" | tee -a /etc/profile >/dev/null
        grep -l "export PGDATABASE=" /etc/profile >/dev/null || echo "export PGDATABASE=mmp" | tee -a /etc/profile >/dev/null
        grep -l "export PGUSER=" /etc/profile >/dev/null || echo "export PGUSER=postgres" | tee -a /etc/profile >/dev/null
        grep -l "#MacPortsPath" /etc/profile >/dev/null \
        || echo "export PATH=/opt/local/lib/postgresql91/bin:/opt/local/bin:/opt/local/sbin:\$PATH  #MacPortsPath" \
        | tee -a /etc/profile >/dev/null
    fi

    #ENVIRONMENT Configuration ~/.bashrc
    grep -l "export EDITOR=" ~/.bashrc >/dev/null || echo "export EDITOR=nano" | tee -a ~/.bashrc >/dev/null
    grep -l "export PGDATABASE=" ~/.bashrc >/dev/null || echo "export PGDATABASE=mmp" | tee -a ~/.bashrc >/dev/null
    grep -l "export PGUSER=" ~/.bashrc >/dev/null || echo "export PGUSER=postgres" | tee -a ~/.bashrc >/dev/null

    if [ `uname` == "Darwin" ];then
    grep -l "type -p -a mc" ~/.bashrc >/dev/null || echo "type -p -a mc >/dev/null && alias mc=\". /opt/local/libexec/mc/mc-wrapper.sh\"" | tee -a ~/.bashrc >/dev/null
    elif [ `uname` == "Linux" ];then
    grep -l "type -p -a mc" ~/.bashrc >/dev/null || echo "type -p -a mc >/dev/null && alias mc=\". /usr/share/mc/bin/mc-wrapper.sh\"" | tee -a ~/.bashrc >/dev/null
    fi    
    
    if [ `uname` == "Darwin" ];then
    #ENVIRONMENT Configuration ~/.profile
        sed -e 's/^export PATH=\/opt\/local\/bin/#export PATH=\/opt\/local\/bin/' ~/.profile > ~/.profiletmp
        mv ~/.profiletmp ~/.profile
    fi    
 
}


#Cross-platform Bucardo reanimate script v3.0
if [ ! -z "$1" ]; then
    while getopts "icd" opt; do
        case $opt in
            c)
                check_ports
                if [[ $? == 1 ]];then
                    echo "OK"
                else
                    echo "PROBLEMS"
                fi
            ;;
            i)
                install_ports
            ;;
            d)  
                check_ports diag
            ;;
        esac
    done
else
    echo "Running without parameters" >&2
fi
