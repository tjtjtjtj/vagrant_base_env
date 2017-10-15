nodes = [
  { :hostname => "vm001",   :ip => "192.168.20.41", :box => "centos7.2" },
  { :hostname => "vm002",   :ip => "192.168.20.42", :box => "centos7.2" },
  { :hostname => "vm003",   :ip => "192.168.20.43", :box => "centos7.2" },
#  { :hostname => "vm004",   :ip => "192.168.20.44", :box => "centos7.2" },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = node[:box]
      nodeconfig.vm.hostname = node[:hostname] + ".box"
      nodeconfig.vm.network :private_network, ip: node[:ip]
      if node[:hostname] == "vm001"
        nodeconfig.vm.provision "shell", :path => "master_setup.sh"
      else
        nodeconfig.vm.provision "shell", :path => "slave_setup.sh"
      end
      if node[:box] == "centos7.2"
        #なぜか、centos7.2のnetwork.serviceをリスタートしないとipが有効にならないので
        nodeconfig.vm.provision "shell", inline: <<-SHELL
        systemctl restart network.service
        echo "systemctl restart network.service" >> /etc/rc.local
        SHELL
      memory = node[:ram] ? node[:ram] : 1024;
      nodeconfig.vm.provider :virtualbox do |vb|
        vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "50",
          "--memory", memory.to_s,
        ]
      end
    end
  end
end
