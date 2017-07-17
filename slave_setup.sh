#!/bin/bash

echo "slave setup shell started"
useradd jenkins
mkdir -p ~jenkins/.ssh
chmod 700 ~jenkins/.ssh
cat /vagrant/jenkins_id_rsa.pub >> ~jenkins/.ssh/authorized_keys
chmod 600 ~jenkins/.ssh/authorized_keys
chown -R jenkins:jenkins ~jenkins/.ssh
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "slave setup shell ended"
