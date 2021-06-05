# Docker PHP
Script for deploy PHP web apps on containers with SSL support.

### Configuration

- `--image` service app image name
- `--host` domain for respond to
- `--src` source project folder
- `--www` public folder name
- `--php` PHP version

### How to Use
```bash
bash deploy.sh --host localhost --src /path/to/source --php 7.1
```

> Use the [Docker Proxy](https://github.com/douglascarlini/docker-proxy) to publish applications.