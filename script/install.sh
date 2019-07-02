#!/bin/bash

cd

# Install Homebrew

echo "Installing Homebrew, A Mac package manager tool"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Check Virtualization for Macbook

echo "Check the virtualization capabilities for the macbook"

sysctl -a | grep machdep.cpu.features

# Install Kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl


# Install Minikube 

brew cask install minikube 


# Install Kubectx && Kubens

brew install kubectx

# Install Helm

brew install kubernetes-helm


# Install AWS CLI

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

unzip awscli-bundle.zip

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install Google Cloud Command line

curl google-cloud-sdk-253.0.0-darwin-x86_64.tar.gz | tar xvz
./google-cloud-sdk/install.sh

