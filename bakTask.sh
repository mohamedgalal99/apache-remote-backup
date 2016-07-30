#!/bin/bash

source fun
backupServer=''
targetServer=0
actionBackup=0
actionRecover=0
actionList=0
#ipCK='[1-2]\{0,1\}[0-9]\{0,1\}[1-9]\{1\}'

while true
do
  #statements
  case $1 in
    -t | --target )
    shift
    backupServer=$1
    targetServer=1
    shift
      ;;
    -b | --backup )
    actionBackup=1
    if [ $actionList != "0" ] || [ $actionRecover != "0" ]
    then
      echo "[Error] Alot of args provided"
      exit 2
    fi
    shift
      ;;
    -l | --list )
    actionList=1
    shift
      ;;
    -r | --recover )
    actionRecover=1
    shift
      ;;
    -h | --help )
    echo "
    This script is used to take,recover and list backup of apache configuration
    files '/etc/apache2' to directory on remote server '/data/backup'.
    [NOTE] to use it, specify target machine (which contain backup) + other option.
     \n
    [OPTIONS]------------------------------------------------------------------------
        -t  --target\t\t IP of other server which backup will be transfare to
        -b  --backup\t\t Take backup to remote server
        -r  --recovery\t To recovr yor configuration file from remote server
        -l  --list\t\t List all backups on remote server\n
     [Example] command -t 192.168.1.1 -l"
    exit 0
      ;;
  -*)
     echo "[Error] Unknow option, give '-h' for help"
     exit 1
     ;;
  *)
     break
     ;;
  esac
done

if [ $targetServer -eq 1 ]
then
  if [ $actionBackup -eq 1 ]; then
    echo '[*] Start backup'
    generateBackup
    transfareBackup $backupServer
  elif [ $actionRecover -eq 1 ]; then
    echo '[*] Start recovery'
    getBackup $backupServer
  elif [ $actionList -eq 1 ]; then
    echo '[*] Start list'
    getList $backupServer
  else
    echo "[Error] No action specified, review the help with --help"
  fi
else
  echo "\n[Error] Please enter terget server to connect to ex:192.168.1.10\n"
fi


#getList
#generateBackup
#transfareBackup
#getBackup
