#cloud-config
users:
  - name: ${vm_user}
    ssh-authorized-keys:
      - ${vm_ssh_public_key}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo, docker
    shell: /bin/bash

ntp:
  pools: ['0.us.pool.ntp.org', '1.us.pool.ntp.org', '2.us.pool.ntp.org', '3.us.pool.ntp.org']