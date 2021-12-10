#!/bin/bash
for i in $(cat $HOME/scripts/fortigate.list | awk '{print $1}');
do
echo "##################################################################"
echo "Testing connection $i"
nc -zvt -w 2 $i 2422

if [ $? -eq 0 ]
then
    echo "########## Start Script: $i on `date +%d-%m-%y_%H:%M:%S` #########"
    echo "Checking if folder is present and create one if it don't."
    test -d $HOME/backup/$i || mkdir $HOME/backup/$i
    echo "Folder OK!"
    cd $HOME/backup/$i
    echo "Downloading Backup File..."
    scp -P 2422 -i $HOME/.ssh/fortigate-backup -o StrictHostKeyChecking=no -o PasswordAuthentication=no fortigate-backup@$i:sys_config .

    if [ $? -eq 0 ]
    then 
        echo "Download Backup File Success!"
        #FGT_NAME=`grep hostname sys_config  | awk '{print $3}' | sed 's/^.//; s/.$//'`
        FGT_NAME=`sed -n '/hostname/{p;q;}' sys_config  | awk '{print $3}' | sed 's/^.//; s/.$//'`
        echo "Renaming file..."
        mv sys_config $FGT_NAME\_`date +"%Y-%m-%d-%T"\.conf`
        echo "File renamed!"
        LAST_FILE=`ls -l| sort -r |awk -F' ' '{print $9}' |sed -n '/[[:alnum:]]/{p;q;}'`
        echo "The newest backup is $LAST_FILE"
        pwd
        echo "########## End Script: $i on `date +%d-%m-%y_%H:%M:%S` ##########" 
        echo "##################################################################"
        echo
    else
        echo "Download Backup File Failed $i on `date +%d-%m-%y_%H:%M:%S`" >> $HOME/log/erro-backup.log
        echo
    fi

    cd $HOME/scripts/
    pwd
else
    echo "No Connection to Host $i on `date +%d-%m-%y_%H:%M:%S`" >> $HOME/log/erro-backup.log
    echo
fi

done