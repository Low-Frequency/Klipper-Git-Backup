#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
        less /home/pi/scripts/klipper_backup_script/manual
        exit 1
elif [[ -n "$1" ]]
then
        echo "Try -h, or --help for the manual"
        exit 2
fi

INTER="o"
while [[ "$INTER" != "y" && "$INTER" != "n" ]]
do
        echo "Right now backups are only done while starting the Pi"
        read -p 'Do you want to do backups during operation on a set timeschedule? [y|n] ' INTER
        case $INTER in
                y)
                        echo "Enabling scheduled backups"
                        sed -i 's/^INTERVAL=.*/INTERVAL=1/g' /home/pi/.config/klipper_backup_script/backup.cfg
                        echo ""
                        UN="o"
                        TM=0
                        while [[ $TM = 0 && "$UN" != "s" && "$UN" != "m" && "$UN" != "h" && "$UN" != "d" ]]
                        do
                                echo "Please specify an interval and a time unit"
                                echo "Available are:"
                                echo "s: seconds"
                                echo "m: minutes"
                                echo "h: hours"
                                echo "d: days"
                                echo "Note that too frequent backups can impact system performance!"
                                echo ""
                                read -p 'Intervals: ' TM
                                read -p 'Unit: ' UN
                        done
                        sed -i "s/^TIME=.*/TIME=$TM/g" /home/pi/.config/klipper_backup_script/backup.cfg
                        sed -i "s/^UNIT=.*/UNIT=$UN/g" /home/pi/.config/klipper_backup_script/backup.cfg
                        ;;
                n)
                        echo "Disabling scheduled backups"
                        sed -i 's/^INTERVAL=.*/INTERVAL=0/g' /home/pi/.config/klipper_backup_script/backup.cfg
                        ;;
                *)
                        echo "Please prvide a valid answer"
                        echo ""
                        ;;
        esac
done
