# HTH-docker

USE AT USER DESCRETION!! HAS NOT BEEN TESTED BY HTH ON HTH NETWORK!!

Full guide: 
Paste medium URL here!

### Preinstall
you first need to install docker and a few needed dependencies. 
    
    bash <(wget -qO- -o- https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/preinstall.sh)
    
This will download the preinstall script and a few more scripts and add them to the PATH. After the install here is finished:

    reboot
    
### Install Nodes

To install only a single node login to your VPS after you rebooted it from the step before:

    install_helpthehomeless.sh
    
This will show you all needed information at the end and might take a minute.  To install multiple (i.E. 3) at once:

    multi_install_helpthehomeless.sh 3
    
Nodes will be enumerated starting with 001.

### Uninstall a node

If you want to uninstall a specific node:

    uninstall_helpthehomeless.sh 001
    
Will uninstall node 001 exchange parameter acordingly.

### helpthehomelessreen-cli

The CLI is wrapped to the specific nodes. Use:

    helpthehomelessreen-cli-001
    
If you want info for all at once there is a wrapper script iterating over all nodes:
    
    helpthehomeless-cli.sh 
    
Masternode status use one of the following:

    helpthehomelessreen-cli-001 masternode status
    helpthehomeless_mn_status.sh
    helpthehomeless_mn_status.sh | grep -E '^helpthehomeless|state'


### Start/Stop/Restart logs

Single nodes:
    
    systemctl start/stop/restart helpthehomeless-001

All all nodes on a Server:

    helpthehomeless_control.sh restart
    
logs:

    journalctl -u helpthehomeless-001
    
rolling logs:

    journalctl -fu helpthehomeless-001

### Repair in case of looped errors:
This will resync a node you want to repair.

    helpthehomeless_repair.sh 001
    
### Update a node to the newest version:

Future updates are easy. Just restart the service and you are done!

    helpthehomeless_control.sh restart
    
### Show all parameters (again)
For a single node:

    chainparams-001.sh 
    
All at once:
    
    helpthehomeless_all_params.sh 
    
### Config location

Enumerated per server exchange `001` accordingly

    /mnt/helpthehomeless/001/
    
### Update Script Versions:

In case anything does not work here copy and paste the following to your console to update all script versions:

    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/install_helpthehomeless.sh -O /opt/helpthehomeless/install_helpthehomeless.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/multi_install_helpthehomeless.sh -O /opt/helpthehomeless/multi_install_helpthehomeless.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_control.sh -O /opt/helpthehomeless/helpthehomeless_control.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_all_params.sh -O /opt/helpthehomeless/helpthehomeless_all_params.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/uninstall_helpthehomeless.sh -O /opt/helpthehomeless/uninstall_helpthehomeless.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_mn_status.sh -O /opt/helpthehomeless/helpthehomeless_mn_status.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless-cli.sh -O /opt/helpthehomeless/helpthehomeless-cli.sh
    wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_repair.sh -O /opt/helpthehomeless/helpthehomeless_repair.sh
chmod +x /opt/helpthehomeless/*.sh
