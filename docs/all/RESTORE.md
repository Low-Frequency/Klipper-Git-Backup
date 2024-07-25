# Restore

The restore process is pretty simple.

On a new installation the script will detect existing configuration files in the repo you've configured. If the instances match the names in the backup, the corresponding configuration will be restored. The script will warn you about instances which couldn't be restored due to the names not matching.

To manually restore a configuration, navigate to the [restore menu](/docs/all/MENUS.md#restore-menu). From there select the instance you want to restore:

![Restore method](/docs/images/restore/restore_method.png)

The script will now ask you, if you want to restore from the local backup, or from GitHub. The local restore method will restore the latest backup, so choose this if you don't want a specific version of your config back.

The first step the script will take is to make a backup of the current config folder (just in case). With the local method, the configuration is immediately restored and you will be asked, if the local backup should be kept. In most cases you can safely delete the local backup. This is just a safety in case you want to review the config from before the restore again.

For the git restore method you'll have to provide some more information to ba able to restore:

![Git restore](/docs/images/restore/git_restore.png)

The script will ask you for a commit SHA to restore. To get this you'll have to navigate to the commits in your repository:

![Repo view](/docs/images/restore/repo_view.png)

From there select the commit you want to restore and copy the full commit SHA by clicking on the button besides the shortened SHA:

![Copy SHA](/docs/images/restore/copy_sha.png)

Paste the commit SHA into the prompt and the restore process will start.

[Go back](/docs/DOCUMENTATION.md)
