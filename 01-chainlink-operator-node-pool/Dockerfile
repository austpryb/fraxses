# Pull base image.
FROM ubuntu:latest

RUN apt-get update -y && \
    apt-get install -y curl keychain python vim ca-certificates curl apt-transport-https lsb-release gnupg unzip software-properties-common jq

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

RUN apt-get update && apt-get install terraform=0.12.28

RUN mkdir /chainlink
 
# Install AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

RUN unzip awscli-bundle.zip

RUN  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Google CLI
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Copy project and change working directory
COPY . /chainlink

WORKDIR /chainlink

