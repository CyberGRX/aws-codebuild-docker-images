# Copyright 2017-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.

FROM ubuntu:18.04

ENV RUBY_VERSION="2.6.3" \
 PYTHON_VERSION="3.7.3" \
 PHP_VERSION=7.3.6 \
 JAVA_VERSION=11 \
 NODE_VERSION="10.16.0" \
 NODE_8_VERSION="8.16.0" \
 GOLANG_VERSION="1.12.5" \
 DOTNET_SDK_VERSION="2.2.300" \
 DOCKER_VERSION="18.09.6" \
 DOCKER_COMPOSE_VERSION="1.24.0" \
 HELM_VERSION="v2.12.2" \
 TERRAFORM_VERSION="0.11.14" \
 KUBE_CTL_VERSION="1.10.13-00" \
 SL1_PMT_VERSION="v1.3.0-custom" \
 MANIFEST_UTILS_VERSION="1.0.0"

#****************        Utilities     ********************************************* 
ENV DOCKER_BUCKET="download.docker.com" \    
    DOCKER_CHANNEL="stable" \
    DOCKER_SHA256="1f3f6774117765279fce64ee7f76abbb5f260264548cf80631d68fb2d795bb09" \
    DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034" \    
    GITVERSION_VERSION="4.0.0" \
    DEBIAN_FRONTEND="noninteractive" \
    SRC_DIR="/usr/src" \
    HELM_SHA="edad6d5e594408b996b8d758a04948f89dab15fa6c6ea6daee3709f8c099df6d"

# Install git, SSH, and other utilities
RUN set -ex \
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update \
    && apt install -y apt-transport-https \
    && apt-get update \
    && apt-get install software-properties-common -y --no-install-recommends \
    && apt-add-repository -y ppa:git-core/ppa \
    && apt-get update \
    && apt-get install git=1:2.* -y --no-install-recommends \
    && git version \
    && apt-get install -y --no-install-recommends openssh-client \
    && mkdir ~/.ssh \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && apt-get install -y --no-install-recommends \
       wget python3 python3-dev python3-pip python3-setuptools fakeroot ca-certificates jq \
       netbase gnupg dirmngr procps \
       tar gzip zip autoconf automake \
       bzip2 file \
       libbz2-dev libc6-dev libcurl4-openssl-dev libdb-dev \
       libncurses5-dev libpq-dev libreadline-dev \
       libsqlite3-dev libssl-dev libtool libwebp-dev \
       libxml2-dev libxslt1-dev libyaml-dev make \
       patch xz-utils zlib1g-dev unzip curl \
       e2fsprogs iptables \
       less groff liberror-perl \
       asciidoc dpkg-dev \
       python-configobj \
       tcl tcl8.6 \
       tk gettext gettext-base libapr1 libaprutil1 xvfb parallel \
       locales rsync\
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

#Download and install helm
RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz --output helm.tar.gz \
    && echo "${HELM_SHA}  helm.tar.gz" | sha256sum -c - \
    #&& sha256sum --check helm.sha \
    && tar -zxf helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm init --client-only \
    && helm plugin install --version master https://github.com/sonatype-nexus-community/helm-nexus-push.git \
    && helm repo add grx-charts https://nexus.grx-dev.com/repository/cybergrx-helm \
    && ls -al /root/.helm/repository/ \
    && rm -rf helm.sha helm.tar.gz linux-amd64/

#Download and install terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin \
    && terraform -version

#Download and install kubectl
RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update && apt-get install -y kubectl=${KUBE_CTL_VERSION} python3-pip

#Upgrade awscli
RUN pip3 install wheel awscli --upgrade

#Download and install custom k8s provider
RUN mkdir -p ~/.terraform.d/plugins/linux_amd64/ \
    && curl -L -o k8s-provider.zip https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/${SL1_PMT_VERSION}/terraform-provider-kubernetes_${SL1_PMT_VERSION}_linux_amd64.zip \
    && unzip k8s-provider.zip \
    && mv terraform-provider-kubernetes_${SL1_PMT_VERSION}_x4 ~/.terraform.d/plugins/linux_amd64/terraform-provider-k8s

# Install Docker
RUN set -ex \
    && curl -fSL "https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    && rm docker.tgz \
    && docker -v \
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    && wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
    && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/dind /usr/local/bin/docker-compose \
# Ensure docker-compose works
    && docker-compose version

RUN set -ex \
    && pip3 install --upgrade setuptools wheel \
    && pip3 install awscli boto3  

VOLUME /var/lib/docker

# Configure SSH
COPY ssh_config /root/.ssh/config

COPY runtimes.yml /codebuild/image/config/runtimes.yml

COPY dockerd-entrypoint.sh /usr/local/bin/

RUN apt-get update \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get install -y python3.7


#****************     GO     **********************************************************
ENV GOLANG_DOWNLOAD_SHA256="aea86e3c73495f205929cfebba0d63f1382c8ac59be081b6351681415f4063cf" \
    GOPATH="/go" \
    DEP_VERSION="0.5.1" \
    DEP_BINARY="dep-linux-amd64"

RUN set -ex \
    && mkdir -p "$GOPATH/src" "$GOPATH/bin" \
    && chmod -R 777 "$GOPATH" \
    && apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
    && apt-get clean \
    && wget "https://dl.google.com/go/go$GOLANG_VERSION.linux-amd64.tar.gz" -O /tmp/golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256 /tmp/golang.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/golang.tar.gz -C /usr/local \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && wget "https://github.com/golang/dep/releases/download/v$DEP_VERSION/$DEP_BINARY" -O "$GOPATH/bin/dep" \
    && chmod +x "$GOPATH/bin/dep"

ENV PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"
#****************     END GO     **********************************************************

