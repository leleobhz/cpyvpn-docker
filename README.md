# Docker implementation of cpyvpn

## Badges

[![Build cpyvpn](https://github.com/leleobhz/cpyvpn-docker/actions/workflows/build-latest.yml/badge.svg)](https://github.com/leleobhz/cpyvpn-docker/actions/workflows/build-latest.yml) [![Build cpyvpn - ipsec branch](https://github.com/leleobhz/cpyvpn-docker/actions/workflows/build-ipsec.yml/badge.svg)](https://github.com/leleobhz/cpyvpn-docker/actions/workflows/build-ipsec.yml)

## Introduction

This container is able to run [cpyvpn](https://gitlab.com/cpvpn/cpyvpn) in a container.

## Requirements

* Run podman as root - vpnc issue

## Images Available: 

| Image | Description | Build periodicity | Archs Available |
|-------|-------------|-------------------|
| [quay.io/pqatsi/cpyvpn:latest](https://quay.io/repository/pqatsi/cpyvpn/tag/latest) | Latest is tagged to last released numbered version | Daily | linux/amd64 <br /> linux/arm/v5 <br /> linux/arm/v7 <br /> linux/arm64/v8 |
| [quay.io/pqatsi/cpyvpn:ipsec](https://quay.io/repository/pqatsi/cpyvpn/tag/ipsec) | Ipsec is tagged to last commit on [ipsec branch](https://gitlab.com/cpvpn/cpyvpn/-/tree/ipsec?ref_type=heads) of cpyvpn | Daily | linux/amd64 <br /> linux/arm/v5 <br /> linux/arm/v7 <br /> linux/arm64/v8 |

## Example

```bash
sudo podman run --init --rm --name cpyvpn --cap-add NET_ADMIN --network=host --device=/dev/net/tun --privileged -e USER='YOUR_USERNAME_HERE' -e PASSWORD='YOUR_PASSWORD_HERE' -e HOST='YOUR_VPN_ENDPOINT_HERE' -e MODE='l' quay.io/pqatsi/cpyvpn:latest
```
