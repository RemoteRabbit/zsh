# Zsh 

## Zsh Setup Script

This script automates the installation and configuration of Zsh (Z Shell) across multiple operating systems, including various Linux distributions and macOS.

### What This Script Does

This setup script performs the following tasks:

1. Detects the operating system (Linux or macOS).
2. Checks if Zsh is installed, and installs it if not present.
3. Verifies if the installed Zsh version is up-to-date, and updates it if necessary.
4. Creates symbolic links to Zsh configuration files in the appropriate locations.

The script supports multiple package managers, including:
- `dnf` (Fedora, CentOS Stream)
- `yum` (older versions of CentOS, RHEL)
- `zypper` (openSUSE)
- `pacman` (Arch Linux and derivatives)
- `brew` (macOS)

## Usage

1. Clone this repository:
```shell
git clone https://github.com/RemoteRabbit/zsh.git ~/repos/personal
```
2. Run the setup script:
```shell
./setup.sh
```
