cat << EOF >> ~/.ssh/config

Host ${hostname}
  Hostname ${hostname}
  User ${user}
  IdentityFile ${identityFile}
EOF

echo usr=${user} >> env
echo IP=${hostname} >> env
echo prv_IP=${private} >> env

