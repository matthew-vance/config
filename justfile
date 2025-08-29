default:
    @just --list

[working-directory: 'ansible']
ansible:
    ansible-playbook playbook.yml --limit $(hostname)

[working-directory: 'dotfiles']
stow tool:
    @stow {{tool}} --dotfiles --target $HOME --verbose

[working-directory: 'dotfiles']
unstow tool:
    @stow -D {{tool}} --dotfiles --target $HOME --verbose
