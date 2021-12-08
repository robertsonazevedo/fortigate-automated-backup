for i in $(cat $HOME/scripts/fortigate.list);
do
ssh administrator@$i -o StrictHostKeyChecking=no -p 2422 < $HOME/scripts/configure-fortigate.conf;
done