# Ansible config for Kubernetes home lab

Ansible config for my home lab that is set up with three Orange Pi 5. It sets up a Kubernetes cluster using k3s.

It contains Ansible playbooks that perform various tasks

## Prerequisites

First of all you have to create a SSH keypair and set it up in each of the hosts. You will have to add the public key of the keypair to the `authorized_keys` file of each host

## How to run

It is very easy. Just have Ansible installed and run

```bash
ansible-playbook <playbook_name>
```

# Playbooks

## update_sources

This playbook task is to replace the apt sources of the Orange Pi Ubuntu distro for the default Ubuntu ARM apt sources

### Variables

| Variable name           | Default value | Description                                                      |
| ----------------------- | ------------- | ---------------------------------------------------------------- |
| ubuntu_version_codename | jammy         | The codename of the Ubuntu version that the hosts have installed |

## Netplan

It will modify the netplan of the hosts in order to set up a static local IP address. For this to work correctly you have to reserve those addresses in you router by setting them as reserved or removing them from the DHCP configuration

For this to work correctly you have to create a `host_map.ini` file that will map each host IP to the new IP. You also need to add the hosts to the `hosts.ini` file under the `netplan_hosts` group. Full example would like like thi:

This playbook has no variables.

```ini
# host_map.ini
[ip_map]
192.168.0.20=192.168.0.200
192.168.0.26=192.168.0.211
192.168.0.27=192.168.0.212

[cloudflare_ip_map]
192.168.0.20=150.0.0.1
192.168.0.26=150.0.0.2
192.168.0.27=150.0.0.3
```

```ini
# hosts.ini
[netplan_hosts]
orangepi@192.168.0.20
orangepi@192.168.0.26
orangepi@192.168.0.27
```

## configure_k3s

It will set up a Kubernetes cluster using K3S. This playbook can configure nodes and _*a single master node*_

Your `hosts.ini` should contain something as follows for this playbook to work:

```ini
[master]
<user>@<ip>

[nodes]
<user>@<ip>
<user>@<ip>

[k3s_cluster:children]
master
nodes

```

For example:

```ini
[master]
user@192.168.0.200

[nodes]
user@192.168.0.211
user@192.168.0.212

[k3s_cluster:children]
master
nodes
```

### Variables

| Variable name     | Default value | Description                                                      |
| ----------------- | ------------- | ---------------------------------------------------------------- |
| master_ip         |               | The codename of the Ubuntu version that the hosts have installed |
| extra_server_args |               | Extra Kubernetes arguments used for the master node              |
| extra_agent_args  |               | Extra Kubernetes arguments used for the nodes                    |
| ansible_user      |               | Non-root user that will be used to connect to the hosts          |
| ansible_sudo_pass |               | Sudo password of the hosts                                       |

## Setup cloudflared

Install `cloudflared` in host and connect to tunnel

### Variables

| Variable name | Default value | Description                         |
| ------------- | ------------- | ----------------------------------- |
| tunnel_token  |               | Token used to connect to the tunnel |
