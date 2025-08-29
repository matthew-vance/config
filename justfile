default:
    @just --list

[working-directory: 'ansible']
run-ansible:
    ansible-playbook playbook.yml --limit $(hostname)

[working-directory: 'dotfiles']
stow tool:
    @stow {{tool}} --dotfiles --target $HOME --verbose --no-folding

[working-directory: 'dotfiles']
unstow tool:
    @stow -D {{tool}} --dotfiles --target $HOME --verbose
