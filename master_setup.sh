#!/bin/bash

ANSIBLE_PLAYBOOK_DIR="/opt/sre/ansible"
ANSIBLE_REPO="https://github.com/tjtjtjtj/ansible-playbook.git"
#jenkinsユーザhomeとは別
JENKINS_HOME="/var/lib/jenkins"

echo "master setup shell started"
useradd jenkins
#ssh-keygen時にディレクトリがないとエラーになるため
mkdir -p ~jenkins/.ssh
chmod 700 ~jenkins/.ssh
chown jenkins:jenkins ~jenkins/.ssh
#if id_rsa already exits,then answer "no"
yes n|ssh-keygen -t rsa -b 4096 -N "" -f ~jenkins/.ssh/id_rsa
#このcat冪等性がない
cat ~jenkins/.ssh/id_rsa.pub >> ~jenkins/.ssh/authorized_keys
chmod 600 ~jenkins/.ssh/authorized_keys
chown -R jenkins:jenkins ~jenkins/.ssh
cp -p ~jenkins/.ssh/id_rsa.pub /vagrant/jenkins_id_rsa.pub
#このecho冪等性がない
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#install ansible 
#The prerequisite is that the eple repository is valid,and python is installed
yum -y install ansible
#git cloneするため
yum -y install git
#ansible-playbookの保存directoryとして利用
mkdir -p ${ANSIBLE_PLAYBOOK_DIR}
git clone ${ANSIBLE_REPO} ${ANSIBLE_PLAYBOOK_DIR}

#install jenkins(ansibleの実行をjenkinsで管理するため）
#The prerequisite is that java is installed
#install後は,ブラウザ(192.168.10.41:8080)で接続し順次設定
yum -y install java-1.8.0-openjdk.x86_64
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins
#jenkinsでのrun-ansibleのための設定関連
#うまくいかないことがあるので,lsしてみる
ls -l /vagrant
ls -l ${JENKINS_HOME}/jobs
cp -r /vagrant/sre ${JENKINS_HOME}/jobs
ls -l ${JENKINS_HOME}/jobs
chown -R jenkins:jenkins ${JENKINS_HOME}/jobs/sre
##create an ansible-vault file (ansible-vault is required at run-ansible runtime)
echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1) > ${JENKINS_HOME}/ansible_vault.conf
chown jenkins:jenkins ${JENKINS_HOME}/ansible_vault.conf
systemctl start jenkins.service
systemctl enable jenkins.service

echo "master setup shell ended"
