# List all available recipes
default:
    @just --list

# Run ansible playbook for this host
[group('ansible')]
[working-directory: 'ansible']
ansible:
    ansible-playbook playbook.yml --limit $(hostname)

# Symlink a tool's configuration files to $HOME
[group('dotfiles')]
[working-directory: 'dotfiles']
stow tool:
    @stow {{tool}} --dotfiles --target $HOME --verbose

# Unlink a tool's configuration files from $HOME
[group('dotfiles')]
[working-directory: 'dotfiles']
unstow tool:
    @stow -D {{tool}} --dotfiles --target $HOME --verbose

# Start Docker containers for this host
[group('docker')]
[working-directory: 'docker']
docker-up:
    #!/usr/bin/env zsh
    compose_file="$(hostname).compose.yml"
    if [[ -f ${compose_file} ]]; then
        echo "Starting containers for $(hostname) using ${compose_file}"
        docker compose -f ${compose_file} up -d
    else
        echo "No compose file found for $(hostname)"
    fi

# Stop Docker containers for this host
[group('docker')]
[working-directory: 'docker']
docker-down:
    #!/usr/bin/env zsh
    compose_file="$(hostname).compose.yml"
    if [[ -f ${compose_file} ]]; then
        echo "Stopping containers for $(hostname)"
        docker compose -f ${compose_file} down
    else
        echo "No compose file found for $(hostname)"
    fi
