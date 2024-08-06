<div align="center">
  <img src="https://avatars.githubusercontent.com/u/61287648" align="center" width="180px" height="180px" alt="Kubernetes logo"/>
  <div>
      <i>Managed with Flux and Renovate. Scanned with Trufflehog via GitHub Actions</i>
  </div>
</div>

<br />

<div align="center">
  
  ![GitHub last commit](https://img.shields.io/github/last-commit/crisszkutnik/home-lab)
  [![Renovate enabled](https://img.shields.io/badge/Renovate-Enabled-brightgreen)](https://github.com/renovatebot/renovate)
  [![K3s](https://img.shields.io/badge/K3s-gold)](https://k3s.io/)
  
</div>

---

## 📖 Overview

This is the repository for my on-premise Kubernetes cluster that runs in my house. It uses GitOps techniques in order to keep the content of this repository in-sync with the cluster. Basic stuff is:

- [Flux](https://github.com/fluxcd/flux2) for GitOps and keeping the cluster in sync with the repo Also
- [Renovate](https://github.com/renovatebot/renovate) to update dependencies
- [Trufflehog](https://github.com/trufflesecurity/trufflehog) and [GitHub Actions](https://github.com/features/actions) for credential scanning and avoid leaking private credentials

In case you want to check the full index of my on-premise stuff, check [crisszkutnik/kubernetes-home-lab](https://github.com/crisszkutnik/kubernetes-home-lab)

## 💻 Setup, deployments and details

The cluster runs a variety of applications for setup and management such as:

- [Grafana](https://grafana.com/) for charts and observability
- [Loki](https://grafana.com/oss/loki/) and [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) for log collection
- [MetalLB](https://metallb.universe.tf/) as load balancer via L2 advertisement
- [NGINX ingress controller](https://docs.nginx.com/nginx-ingress-controller/) is used as an ingress controller
- [Prometheus](https://prometheus-operator.dev/) for metrics and monitoring
- [1Password operator](https://developer.1password.com/docs/k8s/k8s-integrations/) for secret management and automatic redeployment on secret update

It also runs a bunch of other applications that were developed for personal use

## 🔧 Hardware

Not much to add here yet. Hopefully I'll be able to add stuff here eventually

| Device     | Count | CPU            | RAM  | Disk size | OS     | Purpose       |
| ---------- | ----- | -------------- | ---- | --------- | ------ | ------------- |
| OrangePi 5 | 1     | RK3588S 8-core | 4 GB | 64 GB     | Ubuntu | Control plane |
| OrangePi 5 | 2     | RK3588S 8-core | 4 GB | 64 GB     | Ubuntu | Worker        |

## IPs and networking

### Reserved IP spaces on my local network

| Host                  | Address                       |
| --------------------- | ----------------------------- |
| DHCP                  | 192.168.0.10 - 192.168.0.189  |
| K8s load balancer IPs | 192.168.0.190 - 192.168.0.199 |
| Master nodes          | 192.168.0.200 - 192.168.0.210 |
| Nodes                 | 192.168.0.211 - 192.168.1.254 |

#### Nodes IPs

| Host                 | Address       |
| -------------------- | ------------- |
| Control plane node 1 | 192.168.0.200 |
| Worker node 1        | 192.168.0.211 |
| Worker node 2        | 192.168.0.212 |
