VAGRANTFILE_API_VERSION = "2"

WORKER_COUNT = ENV.fetch("WORKER_COUNT", 2).to_i
BASE_IP = "192.168.56."

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/ubuntu-24.04"
    config.ssh.insert_key = false

    # Copy all public keys to the VM
    ['public_key_1', 'public_key_2'].each do |name|
        config.vm.provision "file", run: "always" do |f|
            f.source = File.expand_path("ssh/#{name}.pub", __dir__)
            f.destination = "/tmp/#{name}.pub"
        end
    end

    # Append public keys to authorized_keys
    config.vm.provision "shell", privileged: true, inline: <<-SHELL
        mkdir -p /home/vagrant/.ssh
        chmod 700 /home/vagrant/.ssh

        for key in /tmp/*.pub; do
            cat "$key" >> /home/vagrant/.ssh/authorized_keys
        done

        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant:vagrant /home/vagrant/.ssh
        systemctl restart ssh
    SHELL

    config.vm.define "ctrl" do |ctrl|
        ctrl.vm.hostname = "ctrl"
        ctrl.vm.network "private_network", ip: "#{BASE_IP}100"

        ctrl.vm.provider "virtualbox" do |vb|
            vb.name = "ctrl"
            vb.memory = 4096
            vb.cpus = 1
        end

        # Generate the inventory.cfg file
        ctrl.vm.provision "shell", run: "always" do |s|
            inventory = <<-SCRIPT
echo "[ctrl]" > /vagrant/inventory.cfg
echo "#{BASE_IP}100" >> /vagrant/inventory.cfg
echo "" >> /vagrant/inventory.cfg
echo "[nodes]" >> /vagrant/inventory.cfg
            SCRIPT

            (1..WORKER_COUNT).each do |i|
                inventory += "echo \"#{BASE_IP}10#{i}\" >> /vagrant/inventory.cfg\n"
            end

            s.inline = inventory
        end

        ctrl.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/general.yaml"
            ansible.limit = "ctrl"
            ansible.extra_vars = {
                worker_count: WORKER_COUNT
            }
        end

        ctrl.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/ctrl.yaml"
            ansible.limit = "ctrl"
            ansible.extra_vars = {
                worker_count: WORKER_COUNT
            }
        end
    end

    (1..WORKER_COUNT).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.hostname = "node-#{i}"
            node.vm.network "private_network", ip: "#{BASE_IP}10#{i}"

            node.vm.provider "virtualbox" do |vb|
                vb.name = "node-#{i}"
                vb.memory = 6144
                vb.cpus = 2
            end

            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "ansible/general.yaml"
                ansible.limit = "node-#{i}"
                ansible.extra_vars = {
                    node_id: i,
                    worker_count: WORKER_COUNT
                }
            end

            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "ansible/node.yaml"
                ansible.limit = "node-#{i}"
                ansible.extra_vars = {
                    node_id: i,
                    worker_count: WORKER_COUNT
                }
            end
        end
    end
end
