#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

PLATFORM=`bin/get_plat_tag.sh`


install_erlang()
{
	repo_content=$'[rabbitmq_erlang]
name=rabbitmq-rabbitmq-erlang
baseurl=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/7/$basearch
repo_gpgcheck=1
enabled=1
gpgkey=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq_erlang-noarch]
name=rabbitmq-rabbitmq-erlang-noarch
baseurl=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/7/noarch
repo_gpgcheck=1
enabled=1
gpgkey=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md

[rabbitmq_erlang-source]
name=rabbitmq-rabbitmq-erlang-source
baseurl=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/rpm/el/7/SRPMS
repo_gpgcheck=1
enabled=1
gpgkey=https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md'

	if [ -e '/etc/yum.repos.d/rabbitmq_erlang.repo' ]; then
	  #clear the file
	  truncate -s 0 '/etc/yum.repos.d/rabbitmq_erlang.repo'
	  echo "$repo_content" >> '/etc/yum.repos.d/rabbitmq_erlang.repo'
	else
	  echo "$repo_content" >> '/etc/yum.repos.d/rabbitmq_erlang.repo'
	fi

	install_op=$(yum --disablerepo="*" --enablerepo="rabbitmq_erlang" update -y)
	install_op=$(yum install -y erlang-23.3.4)
	if [ $? -eq 0 ]; then
	   echo "Yum Erlang installation done."
	else
	   echo "Yum Erlang installation failed. ${install_op}"
	fi
}

install_rabbitmq()
{
	mq_repo_content=$'[rabbitmq_server]
name=rabbitmq_server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300'

	if [ -e '/etc/yum.repos.d/rabbitmq_server.repo' ]; then
	  #clear the file
	  truncate -s 0 '/etc/yum.repos.d/rabbitmq_server.repo'
	  echo "$mq_repo_content" >> '/etc/yum.repos.d/rabbitmq_server.repo'
	else
	  echo "$mq_repo_content" >> '/etc/yum.repos.d/rabbitmq_server.repo'
	fi

	install_op=$(yum install rabbitmq-server -y)
	if [ $? -eq 0 ]; then
	   echo "RabbitMQ Server installed."
	else
	   echo "RabbitMQ Server installation failed. ${install_op}"
	fi
}

install_on_ubuntu()
{
	install_op=$(sudo apt-get install rabbitmq-server -y)
	if [ $? -eq 0 ]; then
	   echo "RabbitMQ Server installation complete."
	else
	   echo "RabbitMQ Server installation failed. ${install_op}"
	fi
}

install_on_rhel()
{
	install_erlang
	install_rabbitmq
	start_mq=$(systemctl start rabbitmq-server)
	enable_mq=$(systemctl enable rabbitmq-server)
	echo "RabbitMQ Server installation complete."
}

install_rmq()
{
	echo $PLATFORM | egrep -q "UBUNTU|DEBIAN"
	if [ $? = 0 ]; then
		install_on_ubuntu
	else
		install_on_rhel
	fi
}

	
