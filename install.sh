MINSTALL_REPO='htps://github.com/ThePhisch/rucio-vscode-dev-env'
RUCIO_REPO='https://github.com/rucio/rucio.git'
VSCODE_SOURCE='https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

# Docker install
# TODO: check if already installed
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER

# Git install
sudo apt-get install git

# VSC Check Addons
# TODO: do this

# Folders and cloning
cd ~
mkdir dev
cd dev
git clone $RUCIO_REPO
cd rucio
mkdir .vscode
cd .vscode
git clone $MINSTALL_REPO
mv rucio-vscode-dev-env/* .
rm -rf rucio-vscode-dev-env

# moving keys
cd ~/dev/rucio
cp etc/certs/hostcert_rucio.key.pem .vscode/certs/hostkey.pem
cp etc/certs/hostcert_rucio.pem .vscode/certs/hostcert.pem
cp etc/certs/rucio_ca.pem .vscode/certs/ca-bundle.pem