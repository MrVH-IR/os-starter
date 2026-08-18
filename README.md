# MyConf

Personal Linux developer workstation configuration and setup scripts.

Designed to quickly rebuild my development environment after installing a new OS.

## Supported

* Fedora
* Ubuntu

## Scripts

| Script                    | Description                             |
| ------------------------- | --------------------------------------- |
| `install_requirements.sh` | Install basic CLI and development tools |
| `docker.sh`               | Install and configure Docker            |
| `php.sh`                  | Install PHP and required extensions     |
| `java.sh`                 | Install Java JDK versions               |
| `monitoring.sh`           | Install CLI monitoring tools            |
| `non-free-softwares.sh`   | Install GUI developer applications      |

## Docker Compose

The `docker/` directory contains ready-to-use development environments:

```text
docker/
├── apache.yml
├── mariadb-php-myadmin.yml
├── mongodb.yml
├── mysql_php-myadmin.yml
└── postgres.yml
```

Run any environment with:

```bash
docker compose -f docker/mysql_php-myadmin.yml up -d
```

## Usage

Clone the repository:

```bash
git clone <repository-url>
cd MyConf
```

Make scripts executable:

```bash
chmod +x *.sh
```

Run the required setup scripts:

```bash
./install_requirements.sh
./docker.sh
./php.sh
./java.sh
./monitoring.sh
./non-free-softwares.sh
```

## Notes

* Scripts are designed to be re-runnable where possible.
* PHP and Java versions are managed separately.
* This repository is for personal development environment setup.

