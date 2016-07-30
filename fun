#!/bin/bash

function getList {
  ip=$1
  echo -e "[*] List Backups from remote server\n"
  check=`ssh root@$1 '[ -d /data/backup ] && echo 1 || echo 0'`
  [ check == 0 ] && echo "[Error] Can't find remote backup directory " && exit
  list=(`ssh root@$ip 'ls /data/backup | sort -t '-' -k4 -k3 -k2 -k5'`)
  num=1
  for (( i = 0; i < ${#list[*]}; i++ )); do
    #statements
    echo "[$num] ${list[$i]}"
    ((num++))
  done
}

function generateBackup {
  echo [*] Creating backup
  [ -d /etc/apache2 ] || (echo "[Error] Can't find /etc/apache2" && exit )
  [ -d /tmp/apache ] && (rm -rf /tmp/apache && mkdir /tmp/apache) || mkdir /tmp/apache
  da=`date +%d-%m-%y-%H%M%S`
  cd /etc && tar cf /tmp/apache/apache2-${da}.tar apache2
  echo [*] Backup Created /tmp/apache/apache2-${da}.tar
}

function transfareBackup {
  ip=$1
  da=`date +%d-%m-%y-%H%M%S`
  [ -f /tmp/apache/apache2-${da}.tar ] || (echo "[Error] Can't find backup to transfare" && exit)
  check=`ssh root@$1 '[ -d /data/backup ] && echo 1 || echo 0'`
  [ check == 0 ] && echo "[Error] Can't find remote backup directory " && exit

  echo [*] transfare backup to remote server
  check=`ssh root@$1 '[ -d /data/backup ] && echo 1 || echo 0'`
  [ check == 0 ] && echo "[Error] Can't find remote backup directory " && exit
  rsync -e "ssh -o StrictHostKeyChecking=no" /tmp/apache/apache2-${da}.tar root@$ip:/data/backup
  #scp apache2-${da}.tar root@$ip:/data/backup
  echo "[*] Transfer complete."
}

function getBackup {
  ip=$1
  getList $1
  list=(`ssh root@$ip 'ls /data/backup | sort -t '-' -k4 -k3 -k2'`)
  printf "Choose backup number you want to recover:"; read seletion
  listSize=${#list[*]}
  num=$seletion
  if [ $seletion -le $listSize ] && [ $seletion -ge 1 ]
  then
    ((listSize--))
    ((num--))
    file=${list[$num]}
    echo $file
    [ -d /etc/apache2.old ] && rm -rf /etc/apache2.old
    [ -d /etc/apache2 ] && mv /etc/apache2 /etc/apache2.old
    [ -d /tmp/apache ] && (rm -rf /tmp/apache && mkdir /tmp/apache) || mkdir /tmp/apache
    rsync -e "ssh -o StrictHostKeyChecking=no" root@$ip:/data/backup/${file} /tmp/apache
    cd /tmp/apache && tar xf ${file}
    cp -r /tmp/apache/apache2 /etc/apache2
    for i in `seq 0 ${num}`
    do
        ssh root@$ip "rm /data/backup/${list[$i]}"
    done
    #ssh root@$ip "for i in `seq 0 ${num}`;do rm ${list[$i]}; done"
    echo "[*] Tranfer complete, have a nice day"
    echo "[*] Don't forget to restart apache service ;)"
  else
    echo "[Error] please enter vaild number"
  fi
}

#getList
#generateBackup
#transfareBackup
#getBackup
