echo "####### Upgrading machine versions, this can take a few minutes"
apt update && apt upgrade -y
echo "####### installinging additional dependencies and docker if needed"
if ! apt-get install -y docker.io apt-transport-https curl fail2ban unattended-upgrades ufw dnsutils jq; then
  echo "Install cannot be completed successfully see errors above!"
fi

dockerpwd1=f8459f4db84b2cb38d
dockerpwd2=1bb6ebd0cab41345f3953d

# Create swapfile if less then 2GB memory
totalmem=$(free -m | awk '/^Mem:/{print $2}')
totalswp=$(free -m | awk '/^Swap:/{print $2}')
totalm=$(($totalmem + $totalswp))
if [ $totalm -lt 4000 ]; then
  echo "Server memory is less then 2GB..."
  if ! grep -q '/swapfile' /etc/fstab; then
    echo "Creating a 2GB swapfile..."
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >>/etc/fstab
  fi
fi

#####################
echo "####### Creating the docker mount directories..."
mkdir -p /mnt/HelpTheHomessCoin/ /opt/helpthehomeless/

echo "####### Adding helpthehomeless control directories to path"
if [[ $(cat ~/.bashrc | grep helpthehomeless | wc -l) -eq 0 ]]; then
  echo 'export PATH=$PATH:/opt/helpthehomeless' >>~/.bashrc
fi
source ~/.bashrc

docker login docker.pkg.github.com -u cisnes -p ${dockerpwd1}${dockerpwd2}

## Download the real scripts here
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/install_helpthehomeless.sh -O /opt/helpthehomeless/install_helpthehomeless.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/multi_install_helpthehomeless.sh -O /opt/helpthehomeless/multi_install_helpthehomeless.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_control.sh -O /opt/helpthehomeless/helpthehomeless_control.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_all_params.sh -O /opt/helpthehomeless/helpthehomeless_all_params.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/uninstall_helpthehomeless.sh -O /opt/helpthehomeless/uninstall_helpthehomeless.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_mn_status.sh -O /opt/helpthehomeless/helpthehomeless_mn_status.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless-cli.sh -O /opt/helpthehomeless/helpthehomeless-cli.sh
wget https://raw.githubusercontent.com/HTHcoin/HTH-docker/master/scripts/helpthehomeless_repair.sh -O /opt/helpthehomeless/helpthehomeless_repair.sh
chmod +x /opt/helpthehomeless/*.sh

echo
echo "####### SERVER INSTALLED COPY AND PASTE THE FOLLOWING COMMAND TO INSTALL YOUR FIRST NODE"
echo "Update PATH:"
echo "  source ~/.bashrc"
echo ""
echo "One node:"
echo "  install_helpthehomeless.sh"
echo "Multiple nodes:"
echo "  multi_install_helpthehomeless.sh <numberToInstall>"
