# Ansible playbooks

These are different Ansible playbook that are used to configure nodes from scratch or perform maintenance tasks in the nodes.

- [Ansible playbooks](#ansible-playbooks)
- [Getting started and prerequisites](#getting-started-and-prerequisites)
- [Playbooks](#playbooks)
  - [upgrade](#upgrade)
  - [preconfigure\_node](#preconfigure_node)
  - [setup\_cloudflared](#setup_cloudflared)
  - [setup\_node](#setup_node)
- [Setting up a new node from scratch](#setting-up-a-new-node-from-scratch)

# Getting started and prerequisites

Before using these playbooks, it is important to establish trust between the machine from where you will be running them and each host. To do this, you will need to create a key to authenticate via SSH. After creating the key, add the public key to the `authorized_keys` of the target machines.

This will allow Ansible to authenticate without using password. After that, you can just run any playbook with the following command:

```bash
ansible-playbook ./playbooks/<playbook_name>.yaml
```

# Playbooks

The playbooks available are:

- [upgrade](#upgrade)
- [preconfigure_node](#preconfigure_node)

## upgrade

**Inventory used: `prereq`**

Runs `apt update` and `apt upgrade` to upgrade all hosts

### Variables

None

### Example inventory

```yaml
prereq:
  hosts:
    192.168.0.200:
    192.168.0.201:
    # Other IPs
```

## preconfigure_node

**Inventory used: `prereq`**

Runs initial pre configuration for a node to be converted into a node of the Kubernetes cluster. Will change the netplan, assign static IPs and change the hostname of the target machine.

### Variables

- `ansible_user`: User that is going to be used for SSH
- `ansible_sudo_pass` Sudo password in target machine
- `target_host_ip`: Local static IP that is going to be assigned to the node
- `target_host_cloudflare_ip`: Static IP that is going to be assigned to the node in Cloudflare and is going to be used to route traffic
- `new_hostname`: The new hostname for the node
- `default_interface_name`: The default interface that is used to connect to internet. Is the one that will be used for the netplan and will have the IPs assigned

> [!NOTE]
> This playbook modified the Netplan and IP of the host machine. The last step WILL NOT WAIT for the step to finish since the host will disconnect automatically when the new netplan is appleid

> [!CAUTION]
> If you are adding a brand new node, it is important you add a new **target** in the Terraform configuration for Cloudflare

### Example inventory

```yaml
prereq:
  hosts:
    192.168.0.24: # Local IP of the node you want to preconfigure
      ansible_user: "{{ lookup('ansible.builtin.env', 'ANSIBLE_USER') }}"
      ansible_sudo_pass: "{{ lookup('ansible.builtin.env', 'ANSIBLE_SUDO_PASSWORD') }}"
      ansible_python_interpreter: /usr/bin/python3
      target_host_ip: 192.168.0.200
      target_host_cloudflare_ip: 170.0.0.1
      new_hostname: cluster-master-0
      default_interface_name: eth0
```

## setup_cloudflared

**Inventory used: `setup_cloudflared`**

Will install **Cloudflared**, start the service and try to connect the target machine to the tunnel

> [!CAUTION]
> If you are adding a brand new node, it is important you add a new **target** in the Terraform configuration for Cloudflare

### Variables

- `tunnel_token`: The token used to connect the host machine to the Cloudflare tunnel

### Example inventory

```yaml
setup_cloudflared:
  vars:
    tunnel_token: "{{ lookup('ansible.builtin.env', 'TUNNEL_TOKEN') }}"
  hosts:
    192.168.0.200:
```

## setup_node

**Inventory used: `setup_node`**

This playbook will perform several tasks:

- Install K3s
- Set up Kubernetes and connect to the cluster as master node or agent node
- Install the Flux CLI
- Set up `kubectl` correctly
- Copy `registries.yaml` to configure the GitHub container registry in the node
- Run the `setup_cloudflared` playbook to install Cloudflared and connect to the tunnel

### Variables

- `node_token`: Kubernetes token to connect to the cluster as master node
- `agent_token`: Kubernetes token to connect to the cluster as agent node
- `github_ghcr_registry_username`: Username of the GitHub container registry
- `github_ghcr_registry_personal_access_token`: Access token for the GitHub container registry
- `tunnel_token`: The token used to connect the host machine to the Cloudflare tunnel
- `master_ip`: The IP of any master node of the cluster. Will be used to connect the new target machines to the cluster
- `node_type`: The type of node the host machine will be. Can either be `master` or `agent`.

### Example inventory

```yaml
setup_node:
  vars:
    ansible_user: ubuntu
    ansible_python_interpreter: /usr/bin/python3
    node_token: "{{ lookup('ansible.builtin.env', 'NODE_TOKEN') }}"
    agent_token: "{{ lookup('ansible.builtin.env', 'AGENT_TOKEN') }}"
    github_ghcr_registry_username: "{{ lookup('ansible.builtin.env', 'GITHUB_GHCR_REGISTRY_USERNAME') }}"
    github_ghcr_registry_personal_access_token: "{{ lookup('ansible.builtin.env', 'GITHUB_GHCR_REGISTRY_PERSONAL_ACCESS_TOKEN') }}"
    tunnel_token: "{{ lookup('ansible.builtin.env', 'TUNNEL_TOKEN') }}"
    master_ip: "192.168.0.200"
  children:
    master:
      vars:
        node_type: master
      hosts:
        192.168.0.201:
        192.168.0.202:
    agent:
      vars:
        node_type: agent
      hosts:
        192.168.0.210:
        192.168.0.211:
```

# Setting up a new node from scratch

1. Before starting, some manual commands will have to be performed

```bash
sudo apt update
sudo apt full-upgrade
sudo apt install network-manager
sudo systemctl start NetworkManager.service
sudo systemctl enable NetworkManager.service
```

2. Then, run the `setup_node` playbook. Refer to [setup_node playbook documentation](#setup_node) for more information in the set up required.
