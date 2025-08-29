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
