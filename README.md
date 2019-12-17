# bitcorn-docker

Full guide: 
Paste medium URL here!

### Preinstall
you first need to install docker and a few needed dependencies. 
    
    bash <(wget -qO- -o- https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/preinstall.sh)
    
This will download the preinstall script and a few more scripts and add them to the PATH. After the install here is finished:

    reboot
    
### Install Nodes

To install only a single node login to your VPS after you rebooted it from the step before:

    install_bitcorn.sh
    
This will show you all needed information at the end and might take a minute.  To install multiple (i.E. 3) at once:

    multi_install_bitcorn.sh 3
    
Nodes will be enumerated starting with 001.

### Uninstall a node

If you want to uninstall a specific node:

    uninstall_bitcorn.sh 001
    
Will uninstall node 001 exchange parameter acordingly.

### bitcornreen-cli

The CLI is wrapped to the specific nodes. Use:

    bitcornreen-cli-001
    
If you want info for all at once there is a wrapper script iterating over all nodes:
    
    bitcorn-cli.sh 
    
Masternode status use one of the following:

    bitcornreen-cli-001 masternode status
    bitcorn_mn_status.sh
    bitcorn_mn_status.sh | grep -E '^bitcorn|state'


### Start/Stop/Restart logs

Single nodes:
    
    systemctl start/stop/restart bitcorn-001

All all nodes on a Server:

    bitcorn_control.sh restart
    
logs:

    journalctl -u bitcorn-001
    
rolling logs:

    journalctl -fu bitcorn-001

### Repair in case of looped errors:
This will resync a node you want to repair.

    bitcorn_repair.sh 001
    
### Update a node to the newest version:

Future updates are easy. Just restart the service and you are done!

    bitcorn_control.sh restart
    
### Show all parameters (again)
For a single node:

    chainparams-001.sh 
    
All at once:
    
    bitcorn_all_params.sh 
    
### Config location

Enumerated per server exchange `001` accordingly

    /mnt/bitcorn/001/
    
### Update Script Versions:

In case anything does not work here copy and paste the following to your console to update all script versions:

    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/install_bitcorn.sh -O /opt/bitcorn/install_bitcorn.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/multi_install_bitcorn.sh -O /opt/bitcorn/multi_install_bitcorn.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_control.sh -O /opt/bitcorn/bitcorn_control.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_all_params.sh -O /opt/bitcorn/bitcorn_all_params.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/uninstall_bitcorn.sh -O /opt/bitcorn/uninstall_bitcorn.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_mn_status.sh -O /opt/bitcorn/bitcorn_mn_status.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn-cli.sh -O /opt/bitcorn/bitcorn-cli.sh
    wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_repair.sh -O /opt/bitcorn/bitcorn_repair.sh
    chmod +x /opt/bitcorn/*.sh
