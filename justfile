# Justfile for MacOS config management

run-ansible:
    ansible-playbook -i ansible/inventory.yml ansible/playbook.yml
