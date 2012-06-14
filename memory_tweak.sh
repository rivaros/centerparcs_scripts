
function check_memory() {

    if [ `uname` == "Linux" ];then
        if [ $1 ];then echo "You are on Linux. This option applies only to MacOS";fi
        return 1
    fi

    if [ ! -f /etc/sysctl.conf ];then
        if [ $1 ];then echo "No /etc/sysctl.conf file found";fi
        return 0
    else
        if [ $1 ];then echo "Looks like memory is tweaked";fi
        return 1    
    fi

}

function fix_memory() {
    check_memory
    if [[ $? == 1 ]];then
        echo "This action is not needed"
    else
        cp -f confs/sysctl.conf /etc/sysctl.conf
        echo "Rebooting machine..."
        reboot
        exit
    fi
}


#Cross-platform Bucardo reanimate script v3.0
if [ ! -z "$1" ]; then
    while getopts "icd" opt; do
        case $opt in
            c)
                check_memory
                if [[ $? == 1 ]];then
                    echo "OK"
                else
                    echo "PROBLEMS"
                fi
            ;;
            i)
                fix_memory
            ;;
            d)
                check_memory diag
            ;;
            
        esac
    done
else
    echo "Running without parameters" >&2
fi




