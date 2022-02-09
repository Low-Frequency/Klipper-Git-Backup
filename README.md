# Adding a Klipper config backup script

This script is meant to be set up as a service to backup your klipper config files to a GitHub repository, or Google Drive.

If you have any questions, bug reports or requests feel free to DM me on Discord: **Low_Frequency#0831**

# How does it work?

This script runs when your Pi starts, or if configured even on a set timeschedule. It waits for network connection and then pushes a backup to your specified locations. Every action is logged and the output gets sent to the terminal. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes :wink:

If you want to know what each script does, just execute it with the flags `-h` or `--help` and you get a manual.

This script even sets up custom commands for you to use.

# Setup

## Preparations

Create a GitHub account if you want to store your backup there. If not, just use Google Drive.

If you plan to store the backup on GitHub, go ahead and create a new repo.

## Install

To install this script, `SSH` into your Pi and execute the following command :
```shell
wget -qO setup.sh "https://raw.githubusercontent.com/Low-Frequency/klipper_backup_script/main/setup.sh" && chmod +x setup.sh && ./setup.sh
```

It can take a while for the Google Drive authentication and backup to succeed, so don't panic if the install stops responding for a short period of time.

## Update

I added an update script for easy addition of features in the future. To update, just type `update_bak_util`. If you don't have the update script yet, you need to pull the latest version of the script and do the setup again.

To do this, execute the following command:
```shell
git -C /home/pi/scripts/klipper_backup_script pull origin main && chmod +x /home/pi/scripts/klipper_backup_script/setup.sh && /home/pi/scripts/klipper_backup_script/setup.sh
```

## Adding an SSH key to your GitHub account

The setup script tells you to copy a private key and add it to your GitHub account. To do this just navigate to your *profile* -> *settings* -> *SSH and GPG keys*, add a new key and paste the copied key.

## Making manual backups

To manually create a backup just execute the following command that is created during install:
```shell
backup
```

## Editing the config file

You can customzie how long the log files will be stored, add a backup location and pretty much everything the setup script has asked you during the install.

To customize this, open the config file:
```shell
nano ~/.config/klipper_backup_script/backup.cfg
```

In this file there are all customizable features.

If you want to disable the log rotation completely, just set the `ROTATION` variable to `0`.

To change the log retention time, just change the `RETENTION` variable. Note that the time is calculated in months.

Enabling or disabling backup locations is done via the `GIT` and `CLOUD` variables.

To set up Google Drive as a backup location after you've done the install, just execute this command:
```shell
chmod +x ~/scripts/klipper_backup_script/remote_location.sh && ~/scripts/klipper_backup_script/google_drive.sh
```

If you want to set up GitHub as a backup location after you've done the install, just execute this command:
```shell
chmod +x ~/scripts/klipper_backup_script/remote_location.sh && ~/scripts/klipper_backup_script/git_repo.sh
```

If you want to customize the backup schedule, edit the following variables:

`INTERVAL`: Enable/disable backup schedule.

`TIME`: The schedule interval time.

`UNIT`: The time unit for the interval.

Changing `USER`, `REPO`, `REMOTE`, `FOLDER` and `BREAK` is not advised unless you know what you're doing.

## Further implementation

If you have the [G-code Shell command](https://github.com/th33xitus/kiauh/blob/master/docs/gcode_shell_command.md) extension instealled, you can add the script to your macros in your `printer.cfg`. Just add the following lines to your macro section:
```shell
[gcode_shell_command backup_cfg]
command: sh /home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
timeout: 30.
verbose: True

[gcode_macro BACKUP_CFG]
gcode:
    RUN_SHELL_COMMAND CMD=backup_cfg
```

Since I don't use the shell extension, I haven't tested this. Execution of the script via gcode macro might work, or it might not. I did my best to avoid operations I know won't work with the extension, but it might be that I missed some.

## Restoring the config

The script sets up a custom command for this.

If you need to restore your config files, you have two options:

1. Restoring to your existing installation with the git repo already configured
2. Restoring to a new installation

Just execute the script and follow the instructions:
```shell
restore
```

## Uninstalling the automatic backup utility

I don't know why you wouldn't want to use automatic backups, but I might as well provide you with an easy way to revert all the changes the scripts have done. Just execute this custom command:
```shell
uninstall_bak_util
```

You still have to manually delete your GitHub repo and the SSH keys though.

To delete the SSH keys, just execute this command:
```shell
rm -r ~/.ssh/github_id_rsa*
```

Don't forget to delete the public key in your GitHub profile too!
