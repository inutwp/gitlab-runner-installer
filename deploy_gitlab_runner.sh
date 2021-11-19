#!/bin/bash

detect_os()
{
	if [[ ( -z "${os}" ) ]]; then
		if [ -e /etc/os-release ]; then
     	. /etc/os-release
     	os=${ID}
  		fi
	fi

	if [[ ( -z "${os}" ) ]]; then
		echo "Unknow OS"
		exit 1
  	fi

	os="${os// /}"
}

echo "Checking OS..."

detect_os

echo "OS detecting is $os"
echo

if [[ $os == "rocky" ]]; then
	curl -L --silent https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh > script.rpm.sh
elif [[ $os == "centos" ]]; then
	curl -L --silent https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh > script.rpm.sh
elif [[ $os == "ubuntu" ]]; then
	curl -L --silent https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh > script.deb.sh
fi

echo "Download Gitlab Runner Script..."
GITLAB_RUNNER_DOWNLOAD_STATUS=$?
if [[ GITLAB_RUNNER_DOWNLOAD_STATUS -eq 0 ]]; then
	echo "Success Download Gitlab Runner Script"
	echo
else
	echo "Failed Download Gitlab Runner Script, Connection Problem Mybe..."
	echo
	exit 1
fi

echo "Run Gitlab Runner Script..."
bash script.rpm.sh > /dev/null
RUN_GITLAB_RUNNER_SCRIPT=$?
if [[ RUN_GITLAB_RUNNER_SCRIPT -eq 0 ]]; then
	echo "Success Run Gitlab Runner Script"
	echo
else
	echo "Failed Run Gitlab Runner Script"
	echo
	exit 1
fi

echo "Install Gitlab Runner..."
yum update -y > /dev/null \
	&& yum upgrade -y > /dev/null \
	&& yum install -y gitlab-runner > /dev/null
INSTALL_GITLAB_RUNNER=$?
if [[ INSTALL_GITLAB_RUNNER -eq 0 ]]; then
	echo "Success Install Gitlab Runner"
	echo
	sleep 2
	echo "Check Service Gitlab Runner"
	systemctl status gitlab-runner
else
	echo "Failed Install Gitlab Runner"
	echo
	exit 1
fi

