#!/bin/bash


process_choice() {
    if [[ $2 == 1 ]];then
        arg="-i"
    else
        arg="-d"
    fi

    case $1 in 
        1)
            ./memory_tweak.sh $arg
            ;;
        2)
            ./ports.sh $arg 
            ;;
        3)
            ./project.sh $arg
            ;;
        4) 
            ./apache.sh $arg
            ;;
        5)
            ./stunnel.sh $arg
            ;;
        6)
            ./postgres.sh $arg
            ;;
        7)
            ./install_bucardo.sh $arg
            ;;
        8)
            ./bucardo_configure.sh $arg
            ;;
        9)
        	./cronjobs.sh $arg
        	;;
        99)
            ./uninstall_macports.sh $arg
            ;;
        0)
            exit
            ;;
    esac
}

main_function() {

clear

echo "#########################################################################"
echo "#                                                                       #"
echo "#               MMP ENHANCED INSTALLATOR V 1.0                          #"
echo "#                                                                       #"
echo "#########################################################################"

memorytweak=`./memory_tweak.sh -c`
ports=`./ports.sh -c`
project=`./project.sh -c`
apache=`./apache.sh -c`
stunnel=`./stunnel.sh -c`
postgres=`./postgres.sh -c`
bucardoinstall=`./install_bucardo.sh -c`
bucardoconfigure=`./bucardo_configure.sh -c`
cronjobs=`./cronjobs.sh -c`


echo -e "\n\n\n"
echo  "Checking memory tweak...$memorytweak"
echo  "Checking if ports installed...$ports"
echo  "Checking if website installed...$project"
echo  "Checking Apache configuration...$apache"
echo  "Checking Stunnel configuration...$stunnel"
echo  "Checking Postgres configuration...$postgres"
echo  "Checking if Bucardo installed...$bucardoinstall"
echo  "Checking if Bucardo configured...$bucardoconfigure"
echo  "Checking if cronjobs running...$cronjobs"
echo -e "\n"


choice[1]="1. Apply memory tweak (requires reboot)"
subchoice[1]=1
choice[2]="2. Install ports"
subchoice[2]=1
choice[3]="3. Install MMP website"
subchoice[3]=1
choice[4]="4. Configure Apache"
subchoice[4]=1
choice[5]="5. Configure Stunnel"
subchoice[5]=1
choice[6]="6. Configure Postgres"
subchoice[6]=1
choice[7]="7. Install Bucardo"
subchoice[7]=1
choice[8]="8. Configure Bucardo"
subchoice[8]=1
choice[9]="9. Install cronjobs"
subchoice[9]=1
choice[99]="99. Remove Macports completely"
choice[0]="0. Exit"


availablechoices[1]=1
availablechoices[2]=2
availablechoices[3]=3
availablechoices[4]=4
availablechoices[5]=5
availablechoices[6]=6
availablechoices[7]=7
availablechoices[8]=8
availablechoices[9]=9
availablechoices[10]=99
availablechoices[11]=0


# Determine available choices
if [[ $memorytweak == "PROBLEMS" ]];then
    unset availablechoices[2]
    unset availablechoices[3]
    unset availablechoices[4]
    unset availablechoices[5]
    unset availablechoices[6]
    unset availablechoices[7]
    unset availablechoices[8]
    unset availablechoices[9]
    unset availablechoices[10]
fi
if [[ $ports == "PROBLEMS" ]];then
    unset availablechoices[3]
    unset availablechoices[4]
    unset availablechoices[5]
    unset availablechoices[6]
    unset availablechoices[7]
    unset availablechoices[8]
    unset availablechoices[9]
    unset availablechoices[10] 
fi
if [[ $project == "PROBLEMS" ]];then
    unset availablechoices[4]
    unset availablechoices[5]
    unset availablechoices[6]
    unset availablechoices[7]
    unset availablechoices[8]
    unset availablechoices[9]
    unset availablechoices[10]
fi
if [[ $apache == "PROBLEMS" ]];then
    unset availablechoices[7]
    unset availablechoices[8]
    unset availablechoices[9]
fi
if [[ $stunnel == "PROBLEMS" ]];then
    unset availablechoices[7]
    unset availablechoices[8]
fi
if [[ $postgres == "PROBLEMS" ]];then
    unset availablechoices[7]
    unset availablechoices[8]
fi
if [[ $bucardoinstall == "PROBLEMS" ]];then
    unset availablechoices[8]
fi



for i in "${availablechoices[@]}"
do
    echo ${choice[$i]} 
done
echo -e "\n"

read -p "Enter your choice:" choice
for i in ${availablechoices[@]}
do
      if [ $i == $choice ];then
          if [[ ${subchoice[$i]} ]];then
            read -p "(1)Install or (2)Status? [1]" chk
            if [[ $chk == '' ]]; then
                chk=1
            fi   
          fi
          if [[ $chk == '' ]]; then
                chk=1
          fi          
          process_choice $choice $chk
          match=1
          read -p "press key to continue..."
      fi
done

}

#endless loop
while [[ 1 == 1 ]];do
    main_function
done





