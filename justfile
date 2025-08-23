default:
    @just --list

[working-directory: 'ansible']
run-ansible:
    ansible-playbook playbook.yml --limit $(hostname)

bootstrap:
    ./bootstrap.sh
