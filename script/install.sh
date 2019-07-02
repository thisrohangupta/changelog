#!/bin/bash


# Install Homebrew

echo "Installing Homebrew, A Mac package manager tool"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Check Virtualization for Macbook

echo "Check the virtualization capabilities for the macbook"

sysctl -a | grep machdep.cpu.features

# Install Kubectl

echo "Installing Kubectl, Kubernetes command line tool"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl


# Install Minikube 
echo "Installing Minikube for local kubernetes development"
brew cask install minikube 

# Install Kubectx && Kubens
echo "Installing power user command line tool for Kubernetes Kubectx"
brew install kubectx

# Install Helm
echo "Installing helm, Kubernetes package manager"
brew install kubernetes-helm


# Install AWS CLI
echo "Installing the AWS CLI tool"
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

unzip awscli-bundle.zip

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install Google Cloud Command line
echo "Installing the Google Command line tool"
curl google-cloud-sdk-253.0.0-darwin-x86_64.tar.gz | tar xvz
./google-cloud-sdk/install.sh


echo "***** Blackbelt Install Script Complete *****"