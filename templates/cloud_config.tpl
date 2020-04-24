#cloud-config
users:
  - name: ${vm_user}
    ssh-authorized-keys:
      - ${vm_ssh_public_key}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo, docker
    shell: /bin/bash