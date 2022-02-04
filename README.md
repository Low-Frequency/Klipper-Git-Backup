# Adding a Klipper config backup script

This script is meant to be set up as a service to backup your klipper config files to a GitHub repository.

If you have any questions, bug reports or requests feel free to DM me on Discord: **Low_Frequency#0831**

# How does it work?

This script runs when your Pi starts. It waits for network connection and then pushes the config files to GitHub, if you have modified them since the last commit. Every action is logged and the output gets sent to the terminal. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes 😉

# Setup

## Adding an SSH key to your GitHub account

Connect to your Raspberry Pi via SSH and generate a key pair using the following command: 

```shell
ssh-keygen -t ed25519 -C "mail_of_your_github_account"
```

Save the key pair under `/home/pi/.ssh/github_id_rsa` when it promts you to save it.

When you've created the key pair, add the private key to the ssh-agent:

The following command should tell you the PID under which the ssh-agent runs:
```shell
eval "$(ssh-agent -s)"
```
If the command was successfully run, add the private key with this:
```shell
ssh-add ~/.ssh/github_id_rsa
```

Copy the output of `cat ~/.ssh/github_id_rsa.pub`
On GitHub navigate to your *profile* -> *settings* -> *SSH and GPG keys*, add a new key and paste the copied key.

Before we continue test the SSH connection to GitHub:

```shell
ssh -T git@github.com
```

If the test was successful, you need to add the key permanently. To do this create a config file in the `.ssh` folder:

```shell
nano ~/.ssh/config
```

Add in this line:

```shell
IdentityFile ~/.ssh/github_id_rsa
```

After that you need to set the correct permissions for the config file and you're done with the SSH configuration:

```shell
chmod 600 ~/.ssh/config
```

## Setting up the repo

Initialize the `klipper_config` folder as your repo and push your config for the first time:
```shell
cd ~/klipper_config/
git init
git remote add origin <Your-GitHub-Repo-URL>
git add .
git commit -m "my first backup"
git push -u origin master
```
After that switch over to SSH:

```shell
git remote set-url origin git@github.com:<username>/<your-repository>.git
```

## Setting up the script

Make a folder for your scripts and a folder for the logs:

```shell
mkdir ~/scripts
mkdir ~/git_log
```

After that you can either clone this repository to `~/scripts`, or copy and paste the contents of the [script](klipper_config_git_backup.sh). I recommend cloning the repo since it's less work for you :wink:

For copy/paste:
```shell
nano ~/scripts/klipper_config_git_backup.sh
```

Cloning the repo:
```shell
cd ~/scripts
git clone https://github.com/Low-Frequency/klipper_backup_script
```

After you copied the script, you have to make it executable:
```shell
chmod +x ~/scripts/klipper_config_git_backup.sh
```

At this point you're able to push your klipper config with the script. You can execute it with this command:
```shell
~/scripts/klipper_config_git_backup.sh
```

## Setting up the automation

To automate the backup of you klipper config, we're setting up a service that executes the script after a reboot. To do this, you have to create a service file in `/etc/systemd/system`.

If you cloned the repo, the setup is as easy as executing this command:
```shell
sudo mv ~/scripts/gitbackup.service /etc/systemd/system/gitbackup.service
```

If you want to go the copy/paste route:
```shell
sudo nano /etc/systemd/system/gitbackup.service
```

Then paste the contents of the [service file](gitbackup.service) and save it.

After creating the service file, you have to enable the service and start it:
```shell
sudo systemctl enable gitbackup.service
sudo systemctl start gitbackup.service
```

Now the changes you make in your config will be pushed to GitHub everytime you power on your printer.
When your config gets pushed to GitHub, the commit message will include the date (YYYY-MM-DD) of the backup.
If something fails, you can view the log with the following command:
```shell
cat ~/git_log/<date>
```

With this you should get an idea of where the problem occurred.

## Customizing log rotation

You can customzie how long the log files will be stored, or even turn off log rotation completely.

To customize this, open the script:
```shell
nano ~/scripts/klipper_config_git_backup.sh
```

Notice this line:
```shell
DEL=$((($(date '+%s') - $(date -d '6 months ago' '+%s')) / 86400))
```

This calculates the number of days the logs live in the `git_log` folder. Default is 6 months.

To customize this just change the `'6 months ago'` to a value of your choice, for example `'1 month ago'` for deleting the logs after one month, or even `'12 months ago'` to delete the files after one year.

If you want to disable the log rotation, just comment the last line of the script (add a `#` in front).

## Further implementation

If you have the [G-code Shell command](https://github.com/th33xitus/kiauh/blob/master/docs/gcode_shell_command.md) extension instealled, you can add the script to your macros in your `printer.cfg`. Just add the following lines to your macro section:
```shell
[gcode_shell_command backup_cfg]
command: sh /home/pi/scripts/klipper_config_git_backup.sh
timeout: 30.
verbose: True

[gcode_macro BACKUP_CFG]
gcode:
    RUN_SHELL_COMMAND CMD=backup_cfg
```

# Restoring the config

To restore the your config files, you first have to make the restore script executable:
```shell
chmod +x ~/scripts/restore_config.sh
```

If you need to restore your config files, you have two options:

1. Restoring to your existing installation with the git repo already configured
2. Restoring to a new installation

To restore to the existing installation, execute the following command:
```shell
~/scripts/restore_config.sh restore"
```

To restore to a new installation, execute the following command:
```shell
~/scripts/restore_config.sh new <Your-GitHub-Repo-URL>
```

Note that the restore script isn't tested and might behave funky sometimes.
