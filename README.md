# Adding a Klipper config backup script

This script sets itself up as a service to backup your klipper config files to a GitHub repository, or Google Drive.

In the version prior to this only a default install of klipper was supported. Now you can use this script with systems that were set up with [KIAUH](https://github.com/th33xitus/kiauh) too and it even supports multiple instances of klipper!

If your're migrating from an old version of the script please just set it up from scratch since pretty much everything has changed.

If you have any questions, bug reports or requests feel free to DM me on Discord: **Low_Frequency#0831**

# How does it work?

This script runs when your Pi starts, or if configured even on a set timeschedule. It waits for network connection and then pushes a backup to your specified locations. Every action is logged. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes :wink:

If you want to know what each script does, you can look inside of the manual located inside of the scripts folder.

This script even sets up custom commands for you to use which makes it super easy to backup and restore your configs via the CLI.

# Setup

## Preparations

Create a GitHub account if you want to store your backup there. If not, just use Google Drive.

If you plan to store the backup on GitHub, go ahead and create a new repo.

## Install

To install this script, `SSH` into your Pi and execute the following command :
```shell
wget -qO setup.sh "https://raw.githubusercontent.com/Low-Frequency/klipper_backup_script/main/setup_klipper_backup.sh" && chmod +x setup.sh && ./setup_klipper_backup.sh
```

Be aware that this script only works correctly if the installed version of `git` is 2.28 or newer. Check this with `git --version`. Alternatively the install script will check this for you too.

If the displayed version is prior to 2.28, update your system first! If `apt-get update && apt-get upgrade` doesn't let you update to an newer version of `git`, follow this [guide](https://arslanmalik.medium.com/how-to-install-git-on-raspberry-pi-cdd6ee877e74).

## Update

I removed the update script, since it was a pain to track all the versions and make it compatible to every possible version. The easiest way to update is to just uninstall the backup utility with the `uninstall_bak_util` command and set it up again.

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

If you want to customize the backup schedule, edit the following variables:

`INTERVAL`: Enable/disable backup schedule.

`TIME`: The schedule interval time.

`UNIT`: The time unit for the interval.

Changing the variables below the marked section is not advised unless you know what you're doing.

## Restoring the config

The script sets up a custom command for this.

If you need to restore your config files just execute the following command and follow the instructions to choose from the availabe options:
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
