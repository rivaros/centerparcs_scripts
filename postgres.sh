
function check() {
    
    if [ `uname` == "Linux" ];then
        return 1
    fi

    if [ `uname` == "Darwin" ];then
        if [ ! -d /opt/local/var/db/postgresql91/defaultdb ]; then
            if [[ $1 ]];then echo "ERROR: No initd was run";else return 0;fi
        fi
        if [ ! -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf -o ! -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf.macports ]; then
            if [[ $1 ]];then echo "ERROR: pg_hba.conf not customized";else return 0;fi
        fi   
        if [ ! -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf -o ! -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf.macports ]; then
            if [[ $1 ]];then echo "ERROR: postgresql.conf not customized";else return 0;fi
        fi     
    
        if [ -z "`launchctl list | grep org.macports.postgresql91-server`" ];then
            if [[ $1 ]];then echo "ERROR:org.macports.postgresql91-server not loaded";else return 0;fi  
        fi  
        
        if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
            if [[ $1 ]];then echo "Path not found. Setting...";fi
            export PATH=/opt/local/lib/postgresql91/bin:$PATH
        fi
        export PGUSER=postgres 
        export PGDATABASE=mmp 
    

        psql -d postgres -qAt -c "SELECT 1 FROM pg_roles WHERE rolname='postgres'" | grep -q 1 && postgres_installed=1
        psql -d postgres -qAt -c "SELECT 1 FROM pg_roles WHERE rolname='location'" | grep -q 1 && location_installed=1
        psql -d postgres -qAt -c "SELECT 1 FROM pg_roles WHERE rolname='central'" | grep -q 1 && central_installed=1   
        
        if [[ ! $postgres_installed == 1 ]];then
            if [[ $1 ]];then echo "ERROR:role 'postgres' not found";else return 0;fi 
        fi 
        if [[ ! $location_installed == 1 ]];then
            if [[ $1 ]];then echo "ERROR:role 'location' not found";else return 0;fi 
        fi
        if [[ ! $central_installed == 1 ]];then
            if [[ $1 ]];then echo "ERROR:role 'central' not found";else return 0;fi 
        fi
        
        psql -qAt -c "SELECT 1 FROM pg_extension WHERE extname='dblink'" | grep -q 1 && dblink_installed=1
        if [[ ! $dblink_installed == 1 ]];then
            if [[ $1 ]];then echo "ERROR:dblink extension not installed in mmp database";else return 0;fi
        fi
        
          
            
    fi

    if [[ $1 ]];then echo "All Postgres tests passed.";fi

    return 1

}

function install() {

if [ `uname` == "Linux" ];then
    echo "You need to install Postgres manually on Linux"
fi

if [ `uname` == "Darwin" ];then
    if [ ! -d /opt/local/var/db/postgresql91/defaultdb ]; then
        mkdir -p /opt/local/var/db/postgresql91/defaultdb
        chown postgres:postgres /opt/local/var/db/postgresql91/defaultdb
        chmod 700 /opt/local/var/db/postgresql91/defaultdb
        currentfolder=`pwd`
        cd /opt/local/lib/postgresql91
        su postgres -c '/opt/local/lib/postgresql91/bin/initdb -D /opt/local/var/db/postgresql91/defaultdb'
        cd $currentfolder
    fi
    if [ -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf -a ! -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf.macports ]; then
        cp -f /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf.macports
    fi
    if [ -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf -a ! -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf.macports ]; then
        cp -f /opt/local/var/db/postgresql91/defaultdb/postgresql.conf /opt/local/var/db/postgresql91/defaultdb/postgresql.conf.macports
    fi
    cp -f confs/postgres/pg_hba.conf /opt/local/var/db/postgresql91/defaultdb/pg_hba.conf
    cp -f confs/postgres/postgresql.conf /opt/local/var/db/postgresql91/defaultdb/postgresql.conf
    port unload postgresql91-server
    killall postgresql 2>/dev/null
    port load postgresql91-server
    echo "Waiting 10 secs until postgres is up..."
    sleep 10
    
    if [ -z "`echo $PATH | grep \"/opt/local/lib/postgresql91/bin\"`" ];then
        echo "Path not found. Setting..."
        export PATH=/opt/local/lib/postgresql91/bin:$PATH
    fi
    export PGUSER=postgres
    export PGDATABASE=mmp
    
    psql -d postgres -qAt -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'pybvrb$%'"
    psql -d postgres -qAt -c "CREATE ROLE location WITH LOGIN ENCRYPTED PASSWORD 'pfndjh$%'";
    psql -d postgres -qAt -c "CREATE ROLE central WITH LOGIN ENCRYPTED PASSWORD 'pfndjh$%'";
    psql -d postgres -qAt -c "CREATE DATABASE mmp TEMPLATE=template0 ENCODING='UTF8';"
    #psql -qAt -c "CREATE LANGUAGE plperl;"
    psql -qAt -c "CREATE EXTENSION dblink;"
    #su postgres -c 'pg_ctl -D /opt/local/var/db/postgresql91/defaultdb reload'
    #Database scripts
fi
    
cp -f db.dump ~/db.dump

#Restore location
echo -e "Would you like to restore local database now?\n\n"
echo "Available choices:"
echo "yes - restore"
echo "no - skip the step"
echo -e "\n\n"
    
read -p "Enter your choice:[yes]" choice  
    
if [[ $choice == "yes"  || $choice == '' ]];then
     /bin/bash /centerparcs/bin/scripts_linux/restore-mmp.sh
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
                    echo "PROBLEMS"
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




