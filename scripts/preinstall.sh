echo "####### Upgrading machine versions, this can take a few minutes"
apt update && apt upgrade -y >/dev/null 2>&1
echo "####### installinging additional dependencies and docker if needed"
if ! apt-get install -y docker.io apt-transport-https curl fail2ban unattended-upgrades ufw dnsutils jq >/dev/null; then
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
mkdir -p /mnt/bitcorn/ /opt/bitcorn/

echo "####### Adding bitcorn control directories to path"
if [[ $(cat ~/.bashrc | grep bitcorn | wc -l) -eq 0 ]]; then
  echo 'export PATH=$PATH:/opt/bitcorn' >>~/.bashrc
fi
source ~/.bashrc

docker login docker.pkg.github.com -u cisnes -p ${dockerpwd1}${dockerpwd2}

## Download the real scripts here
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/install_bitcorn.sh -O /opt/bitcorn/install_bitcorn.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/multi_install_bitcorn.sh -O /opt/bitcorn/multi_install_bitcorn.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_control.sh -O /opt/bitcorn/bitcorn_control.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_all_params.sh -O /opt/bitcorn/bitcorn_all_params.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/uninstall_bitcorn.sh -O /opt/bitcorn/uninstall_bitcorn.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_mn_status.sh -O /opt/bitcorn/bitcorn_mn_status.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn-cli.sh -O /opt/bitcorn/bitcorn-cli.sh
wget https://raw.githubusercontent.com/BITCORNProject/BITCORN-docker/master/scripts/bitcorn_repair.sh -O /opt/bitcorn/bitcorn_repair.sh
chmod +x /opt/bitcorn/*.sh

echo
echo "####### SERVER INSTALLED COPY AND PASTE THE FOLLOWING COMMAND TO INSTALL YOUR FIRST NODE"
source ~/.bashrc
echo "One node:"
echo "  install_bitcorn.sh"
echo "Multiple nodes:"
echo "  multi_install_bitcorn.sh <numberToInstall>"