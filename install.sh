MINSTALL_REPO='https://github.com/ThePhisch/rucio-vscode-dev-env'
RUCIO_REPO='https://github.com/rucio/rucio.git'
VSCODE_SOURCE='https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'

function bigwrite() {
  echo ""
  echo ""
  echo "=============================================================="
  echo "$1"
  echo "=============================================================="
}

# Packages install
bigwrite "Installing Other Dependencies"
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Docker install
bigwrite "Installing Docker"
DOCKERPACKAGES=("docker-ce" "docker-ce-cli" "containerd.io" "docker-compose-plugin")
ALLINSTALLED=1

for pname in "${DOCKERPACKAGES[@]}"; do
  if [[ -z $(dpkg-query -s $pname | grep 'Status: install ok installed') ]]; then
    echo "$pname NOT installed"
    ALLINSTALLED=0
  else
    echo "$pname installed"
  fi
done

if [[ $ALLINSTALLED -eq 1 ]]; then
  echo "All installed"
else
  echo "Not all installed"
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install ${DOCKERPACKAGES[@]}

  sudo usermod -aG docker $USER
fi



# VSC Check Addons
bigwrite "VS Code Extensions"
if [[ -n $(code --list-extensions | grep ms-azuretools.vscode-docker) ]]; then
  VSC_DOCKER_VERSION=$(code --list-extensions --show-versions | grep ms-azuretools.vscode-docker | awk -F@ '{print $2}')
  echo "Found VS Code Docker Extension, version $VSC_DOCKER_VERSION"

  if [[ -z  $(echo $VSC_DOCKER_VERSION | awk -F. '{if ($1 >= 1 && $2 >= 23) print }') ]]; then
    echo "Version is below 1.23, Updating..."
    code --install-extension ms-azuretools.vscode-docker --force --wait
  else
    echo "Version is okay"
  fi
else
  echo "Did not find VS Code Docker Extension, Installing..."
  code --install-extension ms-azuretools.vscode-docker --force --wait
fi
echo "Dealing with VS Code Extensions Completed!"


# Folders and cloning
bigwrite "Creating Folder Structure and Cloning the Testenv Repo"
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
bigwrite "Moving certificates around"
cd ~/dev/rucio
cp etc/certs/hostcert_rucio.key.pem .vscode/certs/hostkey.pem
cp etc/certs/hostcert_rucio.pem .vscode/certs/hostcert.pem
cp etc/certs/rucio_ca.pem .vscode/certs/ca-bundle.pem
