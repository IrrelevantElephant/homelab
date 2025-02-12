# Preparing the nodes

These steps prepare the initial server node.

## Installation

1. Use Raspbery Pi Imager to install a Linux distro onto the Pi's microSD card.
2. Upgrade packages

```bash
sudo apt update -y && sudo apt upgrade -y
```

3. Enable cgroups in boot parameters

```bash
sudo sed -i \
'$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' \
/boot/firmware/cmdline.txt
```

4. Restart

```bash
sudo reboot
```

5. Install K3s

See https://docs.k3s.io/quick-start for details.

```bash
curl -sfL https://get.k3s.io | sh -
```

## Copy Kubeconfig & node token

1. Interpolate the config with your local `~/kube/config` file, adjusting the `server` entry from `127.0.0.1` to the Pi's IP address.

```bash
sudo cat /etc/rancher/k3s/k3s.yaml
```

2. Save the node token in order to add additional agent nodes later.

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

## Provision a static IP address

## Add agent nodes

Follow the steps above, replacing Installatiob:5 with the following:

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://serverip:6443 K3S_TOKEN=nodetoken sh -
```

This will allow your agent node to connect attach itself to the cluster.
