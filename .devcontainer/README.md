# Puppet Development Container

This devcontainer provides a consistent development environment for the puppet-antelope module with all necessary tools pre-installed.

## Features

- **Official PDK Image** - Uses `puppet/pdk:3.4.0` as base image
- **PDK (Puppet Development Kit)** - Pre-installed and ready to use
- **Puppet VS Code Extension** - Syntax highlighting and IntelliSense
- **Git & GitHub CLI** - Version control and collaboration tools
- **Docker-in-Docker** - For containerized testing scenarios

## Getting Started

### With Docker
1. Open this repository in Visual Studio Code
2. When prompted, click "Reopen in Container" or use Command Palette: `Dev Containers: Reopen in Container`
3. The container will build and install all development dependencies automatically

### With Podman
1. Configure VS Code to use Podman by adding to your settings.json:
   ```json
   {
     "dev.containers.dockerPath": "podman",
     "dev.containers.dockerComposePath": "podman-compose"
   }
   ```
2. Or set environment variables:
   ```bash
   export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
   ```
3. Follow the same steps as Docker above

### Usage
Once the container is running, you can use PDK commands:
```bash
pdk validate
pdk test unit
pdk update
```

## Installed Tools

- PDK (Puppet Development Kit)
- Puppet Agent
- Ruby development tools (bundler, rake, rspec)
- puppet-lint for code quality

## Troubleshooting

### General Issues
- If you encounter issues with PDK templates, the fresh container environment should resolve most caching problems that can occur with local PDK installations.

### Podman-specific Issues
- **SELinux**: If using Podman with SELinux, you may need to add `:Z` to volume mounts
- **Rootless**: Ensure podman is running in rootless mode for security
- **Socket**: Make sure the podman socket is running: `systemctl --user start podman.socket`

### Volume Permissions
- On some systems, you may need to adjust volume permissions
- Consider using `podman unshare chown` if needed

## Volume Mounts

- `puppet-devcontainer-gems` - Persists Ruby gems across container rebuilds

## Compatibility

This devcontainer works with:
- **Docker Desktop** (Windows, macOS, Linux)
- **Docker Engine** (Linux)
- **Podman** (Linux, macOS, Windows via WSL2)
- **Podman Desktop** (Windows, macOS, Linux)