#!/bin/bash

function uninstall_ports() {
    if [ `uname` == "Darwin" ];then
        echo "Attention: It will destroy all macports!!!"
        read -p "Continue?[no]" choice
        if [[ $choice != "yes" ]];then
            echo "Uninstall cancelled"
            exit
        fi
                
        
        
        port -fp uninstall --follow-dependents installed
        rm -rf \
         /opt/local \
         /Applications/DarwinPorts \
         /Applications/MacPorts \
         /Library/LaunchDaemons/org.macports.* \
         /Library/Receipts/DarwinPorts*.pkg \
         /Library/Receipts/MacPorts*.pkg \
         /Library/StartupItems/DarwinPortsStartup \
         /Library/Tcl/darwinports1.0 \
         /Library/Tcl/macports1.0 \
         ~/.macports
    elif [ `uname` == "Linux" ];then
        echo "You are on Linux. We assume you have all software prerequisites installed"
        read -p "Press any key to continue..."
    fi
}


#Cross-platform Bucardo reanimate script v3.0
if [ ! -z "$1" ]; then
    while getopts "i" opt; do
        case $opt in
            i)
            uninstall_ports
            ;;
        esac
    done
else
    echo "Running without parameters" >&2
fi

