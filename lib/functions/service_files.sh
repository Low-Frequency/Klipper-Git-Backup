#!/bin/bash

SERVICE_FILE=$(
  cat <<-EOF
[Unit]
Description=Klipper config backup service
Documentation="https://github.com/Low-Frequency/klipper_backup_script"

[Service]
Type=simple
User=$USER
ExecStart=$SCRIPTPATH/backup.sh
EOF
)

SERVICE_TIMER=$(
  cat <<-EOF
[Unit]
Description=Timer for kgb.service
Documentation="https://github.com/Low-Frequency/klipper_backup_script"
After=network-online.target
Requires=network-online.target

[Timer]
replace_interval
Unit=kgb.service
Persistent=replace_persist

[Install]
WantedBy=multi-user.target timers.target
EOF
)
