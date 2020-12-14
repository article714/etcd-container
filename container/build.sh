#!/bin/bash

#set -x

apt-get update

# Generate French locales
localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

export LANG=en_US.utf8

# Install basic needed packages
LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends wget curl gnupg ca-certificates runit rsyslog logrotate

apt-get upgrade -yq

# install etcd
ETCD_VER=v3.4.14

# etcd user should have a > 1000 gid to ease uid/gid mapping in docker
addgroup --gid 1020 etcd

adduser --system --home /var/lib/etcd --gid 1020 --uid 1020 --quiet etcd
adduser etcd syslog

mkdir -p /home/etcd
mkdir -p /container/data
chown -R etcd. /home/etcd
chown -R etcd. /container/data
chmod -R 770 /home/etcd
chmod -R 770 /container/data

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    exit -1
fi
tar xzvf /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C /usr/bin --strip-components=1
if [ $? -ne 0 ]; then
    exit -1
fi
rm -f /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz

/usr/bin/etcd --version
if [ $? -ne 0 ]; then
    exit -1
fi
/usr/bin/etcdctl version
if [ $? -ne 0 ]; then
    exit -1
fi

#--
# Cleaning

apt-get -yq clean
apt-get -yq autoremove
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/ci
rm -f tmp/*_dependencies.txt
