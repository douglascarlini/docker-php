# Docker PHP
Script for deploy PHP web apps on containers with SSL support.

### Configuration

- `--image` Service Docker image name
- `--https` Open external HTTPS port
- `--http` Open external HTTP port
- `--host` Domain for respond to
- `--src` source project folder
- `--www` public folder name
- `--php` PHP version
- `--up` Up service

### How to Use
```bash
# No mapped ports (use with reverse proxy)
bash deploy.sh --host my.awesome.app --src /path/to/source --php 7.1


# Mapped 80/433 ports
bash deploy.sh --host my.awesome.app --src /path/to/source --http 8080 --https 8443 --php 5.6
```

> Use the [Docker Proxy](https://github.com/douglascarlini/docker-proxy) to publish applications.
