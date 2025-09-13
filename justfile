# List all available recipes
default:
    @just --list

# Symlink a tool's configuration files to $HOME
[group('dotfiles')]
stow tool:
    @stow {{tool}} --dotfiles --target $HOME --verbose

# Unlink a tool's configuration files from $HOME
[group('dotfiles')]
unstow tool:
    @stow -D {{tool}} --dotfiles --target $HOME --verbose
