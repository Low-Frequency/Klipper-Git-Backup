# Menu functions

This is an overview over the specific functions that can be called from menus.

## Help

By typing `h` on all menu screens, you can call a quick help, which will briefly explain all actions that can be done through the current menu.

[Go back](/docs/DOCUMENTATION.md)

## Refresh the menu

Most menus don't automatically update the status column. This is done to keep the history of actions visible. You can refresh the status column manually by executing the `refresh menu` action.

[Go back](/docs/DOCUMENTATION.md)

## Showing the current running config

This function prints the current running configuration of the script. This includes config cahnges made in the current session. It's useful to double check before saving the config.

[Go back](/docs/DOCUMENTATION.md)

## Saving the config

This function saves the current running vonfiguration to the config file. Use this to update any configuration you might want to make after installing.

[Go back](/docs/DOCUMENTATION.md)

## Install

This function installs the script. If the repository you specified during configuration, the installer will prompt you to restore the found configuration. Otherwise it will perform an initial backup.

[Go back](/docs/DOCUMENTATION.md)

## Uninstall

This removes the script and all of it's dependencies from your system.

[Go back](/docs/DOCUMENTATION.md)

## Migrate to v2

This will automatically migrate your configuration from v1 to the v2 update. Due to a change in how backups are handled, the v1 config will not work with the v2 update. Before the migration, you'll need to follow the steps described in the [setup](/docs/all/SETUP.md) documentation.

[Go back](/docs/DOCUMENTATION.md)
