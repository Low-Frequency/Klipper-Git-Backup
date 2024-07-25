# Menus

In this document you'll get all information about the different config menus and functions which can be called from the main menu.

The general structure of the menus is as follows:
On the left side you'll have several functions you can execute. On the right side you'll find the current status of configurations assiciated with the menu you're in. The status doesn't update automatically. This is done to keep the history of actions you took visibla. Upon changing the menu, the status gets refreshed. To refresh the status in the current menu you can execute the [refresh menu](/docs/all/MENU_FUNCTIONS.md#refresh-the-menu) function.

## Main menu

![Main menu](/docs/images/readme/main_menu.png)

The main menu is the entrypoint for the script. It gives you options to start configuring, as well as the most used operations of the script.

On first execution you'll want to enter the [configuration menu](#configuration-menu). To do that simply select action 1 (configure). Further information can be found in the [configuration menu](#configuration-menu) section.

All other actions that can be executed from here will call different functions. Most of them should be self explanatory, but here's a list of the functions you can execute:

#### Install

This will install the script with the current configuration. The script will iterate through a fair amount of dependency checks and subroutines.

At first SSH will be set up. During the setup the script will check if [GitHub CLI](https://cli.github.com/) needs to be installed and will install it with all dependencies. This is needed to ensure that the following installation steps can be executed. However the installation of [GitHub CLI](https://cli.github.com/) will be skipped, if a custom git server is configured. It's up to the user to make sure all dependecies are met if that's the case.
When [GitHub CLI](https://cli.github.com/) is installed, the script will check if the configured repository already exists. If it doesn't, it will be created. To finalize the SSH setup a check is run to determine if there is an SSH key pair already present, or if a new one has to be created. The public key is then added to your GitHub account.

Now the main installation routine will start. There is a `git` version check implemented to make sure the software which the scrip is based on meets the requirement. If it doesn't, the script will uninstall `git` and install the latest version from source. This can take a while, so be patient if it happens.
If the requirement is met, the script will continue to congigure `git` with the configuration optins you gave it. It sets the username, your mail address, the default branch and a few other options to ensure the correct behavior when performing backups.
The next step is to clone the created repository and check if therealready is data in it. If the script detects files in the repository, an automatic restore process can be triggered. If there are no files detected, an initial backup will be created.

Finally it's time to set up the automation. The script creates a systemd service file and a timer unit, which will control how and when backups are made. After that's done, the installation is complete and the backup service is up and running. If you want to confirm that, you can simply execute `sudo systemctl list-timers kgb` to see the last and next backup execution.

#### Update

This option lets you update [KGB](https://github.com/Low-Frequency/Klipper-Git-Backup). It will simply reset KGB (don't worry, your config will still be there) and pull the latest version from GitHub.

#### Backup

This will trigger a manual backup. It executes the same script that the automatic backup uses.

#### Restore

This will lead to the [restore menu](#restore-menu). Further information can be found in the [restore menu](#restore-menu) section.

#### Migrate to v2

This will start the migration from v1 to v2. It will basically run through the installation process minus a few dependecy checks, which are already satisfied through the previous installation. The migration tool will make sure that all configuration options that have been changed in version 2 will be altered to represent a valid version 2 config. This includes the configured repository, as well as the config folder list.

#### Uninstall

This will uninstall [KGB](https://github.com/Low-Frequency/Klipper-Git-Backup) and all of its dependecies.

[Go back](/docs/DOCUMENTATION.md)

## Restore menu

![Restore menu](/docs/images/menus/restore_menu.png)

The restore menu is the only menu of this script that is generated based on your config. It will show you the instances that are configured for backups. To restore an instance simply select it. Further information about the restore process can be found [here](/docs/all/RESTORE.md).

[Go back](/docs/DOCUMENTATION.md)

## Configuration menu

![Configuration menu](/docs/images/menus/configuration_menu.png)

The configuration menu gives an overview over all configurable options. From here you can start configuring to the different modules of the script, as well as check and save the config.

[Go back](/docs/DOCUMENTATION.md)

## GitHub menu

![GitHub menu](/docs/images/menus/github_menu.png)

The most important menu. From here you can configure your GitHub account, which folders to back up, etc.

[Go back](/docs/DOCUMENTATION.md)

## Log rotation menu

![Log rotation menu](/docs/images/menus/log_rotation_menu.png)

From this menu you can control how long the logs will be kept. The minimum retention time is one month.

[Go back](/docs/DOCUMENTATION.md)

## Scheduled backups menu

![Scheduled backups menu](/docs/images/menus/scheduled_backups_menu.png)

From here you can activate and configure scheduled backups. This is helpful, if you always keep your printer running.

[Go back](/docs/DOCUMENTATION.md)

## Advanced menu

![Advanced menu](/docs/images/menus/advanced_menu.png)

The advanced menu lets you set your own git server. Only configure things in here if you know what you're doing. Support for this will be limited, so if you break stuff, be prepared to fix it yourself!

[Go back](/docs/DOCUMENTATION.md)
