#!/bin/bash
set -e

echo "=============================="
echo " DevOps Server Setup Started "
echo "=============================="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS"

# Update system
echo "Updating system packages..."
if [[ "$OS" == "ubuntu" ]]; then
    sudo apt update -y
    sudo apt install -y curl unzip git ca-certificates
elif [[ "$OS" == "amzn" ]]; then
    sudo yum update -y
    sudo yum install -y curl unzip git
else
    echo "Unsupported OS"
    exit 1
fi

# ---------------- Docker ----------------
echo "Installing Docker..."
if [[ "$OS" == "ubuntu" ]]; then
    sudo apt install -y docker.io
elif [[ "$OS" == "amzn" ]]; then
    sudo amazon-linux-extras install docker -y
fi

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# ---------------- AWS CLI ----------------
echo "Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# ---------------- kubectl ----------------
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# ---------------- Validation ----------------
echo "Validating installations..."

echo "Docker version:"
docker --version

echo "AWS CLI version:"
aws --version

echo "kubectl version:"
kubectl version --client

echo "Git version:"
git --version

echo "=============================="
echo " Setup Completed Successfully "
echo "=============================="
