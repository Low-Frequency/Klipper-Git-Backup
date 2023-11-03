#!/bin/bash

SERVICE_FILE=$(cat <<- EOF
[Unit]
Description=Klipper config backup service
Documentation="https://github.com/Low-Frequency/klipper_backup_script"
After=network-online.target
Requires=network-online.target

[Service]
Type=simple
User=$(echo $USER)
ExecStart=$(echo $SCRIPTPATH)/backup.sh

[Install]
WantedBy=multi-user.target
EOF
)

SERVICE_TIMER=$(cat <<- EOF
[Unit]
Description=Timer for kgb.service
Documentation="https://github.com/Low-Frequency/klipper_backup_script"
After=network-online.target
Requires=network-online.target

[Timer]
$(echo $INTERVAL)
Unit=kgb.service
Persistent=$(echo $PERSISTENT)

[Install]
WantedBy=multi-user.target
EOF
)
