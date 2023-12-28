# Docker implementation of cpyvpn

## Introduction

This container is able to run [cpyvpn](https://gitlab.com/cpvpn/cpyvpn) in a container.

## Requirements

* Run podman as root - vpnc issue

## Example

```bash
sudo podman run --init --rm --name cpyvpn --cap-add NET_ADMIN --network=host --device=/dev/net/tun --privileged -e USER='YOUR_USERNAME_HERE' -e PASSWORD='YOUR_PASSWORD_HERE' -e HOST='YOUR_VPN_ENDPOINT_HERE' -e MODE='l' quay.io/pqatsi/cpyvpn:latest
```
