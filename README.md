# DISCLAIMER

**This version is under development and does not work in the current state!**

## What can you expect of the new version?

The new version will have a UI heavily influenced by KIAUH. Also the generation of the config and the installation process will be reworked completely.

Due to the UI the configuration will take place before the actual install. You can preview the configuration at any point from the main menu.

Here's a preview if you're curious:

![Preview of the main UI](/docs/images/preview.png)

As a side effect the install script can be used to edit the config file if you want to make some changes to it.

Also there will only be one custom command: `kgb`

Google Drive support has now been completely removed from the source code. If there's enough demand, I'll consider adding it again, but for now I'll keep it as it is.

The UI is almost completely redone from the previous version and almost fully tested. In the next step I'll verify that I didn't miss some settings and test all functions of the UI again. After that the main part of the script get's a mekeover.

# Adding a Klipper config backup script

This script sets itself up as a service to backup your klipper config files to a GitHub repository.

In the version prior to this only a default install of klipper was supported. Now you can use this script with systems that were set up with [KIAUH](https://github.com/th33xitus/kiauh) too and it even supports multiple instances of klipper!

If your're migrating from an old version of the script please use the uninstall script and set it up from scratch again. Repositories that were already set up will be reused. You still have to configure them in the UI though, so the script recognizes them.

If you have any questions, bug reports or requests feel free to open an issue.

# How does it work?

This script runs when your Pi starts, or if configured on a set timeschedule. It waits for network connection and then pushes a backup to your specified locations. Every action is logged. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes :wink:

This script sets up a custom command for you as a convenience feature to launch the UI.

# Setup

## Preparations

Create a GitHub account and create a new repo.

## Install

To install this script, `SSH` into your Pi and execute the following command:
```shell
wget -qO setup_klipper_backup.sh "https://raw.githubusercontent.com/Low-Frequency/klipper_backup_script/main/setup_klipper_backup.sh" && chmod +x setup_klipper_backup.sh && ./setup_klipper_backup.sh
```

Be aware that this script only works correctly if the installed version of `git` is 2.28 or newer. The install script will check that for you and install the latest version of `git` from the source if the requirement isn't met.

Alternatively you can check this with `git --version` and follow this [guide](git-update.md) to update it manually.

## Adding an SSH key to your GitHub account

The setup script tells you to copy a private key and add it to your GitHub account. To do this just navigate to your *profile* -> *settings* -> *SSH and GPG keys*, add a new key and paste the copied key.

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

## Google Drive support

Google drive support has been disabled due to some changes in the setup of rclone. You can still try to use it, but you have to manually set it up and edit the config file with the respective options (the code for Google Drive backups is still there). But be aware that this is untested in the current version and I might deny support (depending on the issue) when things go wrong.