# Zsh 

Zsh (Z Shell) is an extended version of the Bourne Shell (sh), with many improvements and features. It offers powerful command-line editing, shared command history, and advanced tab completion, among other features.

## Why Use Zsh?

Zsh provides several advantages over traditional shells:
- Enhanced productivity with better auto-completion and correction
- Rich customization options
- Improved scripting capabilities
- Cross-platform consistency

## Prerequisites

- Sudo access (for Linux systems)
- Internet connection
- Git (for cloning the repository)

## Configuration

After running the setup script, you can further customize your Zsh environment by editing the `.zshrc` file in your home directory.

## Troubleshooting

If you encounter any issues, please check the following:
- Ensure you have the necessary permissions to install packages
- Verify your internet connection
- Check if the required package managers are available on your system

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

## License

This project is released into the public domain using the Unlicense. For more information, please see the [UNLICENSE](UNLICENSE) file in this repository or visit [unlicense.org](https://unlicense.org)
