# Adding a Klipper config backup script

This script is meant to be run as a cronjob to backup your klipper config files to a GitHub repository.


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

After that you can either clone this repository to `~/scripts`, or copy and paste the contents of the [script](klipper_config_git_backup.sh"). I recommend cloning the repo since it's less work for you :wink:

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

To automate the backup of you klipper config, we're setting up a cronjob that executes the script after a reboot:
```shell
crontab -e
```

Choose the editor you want (I use nano for simplicity) and add the following line at the end of the file:
```shell
@reboot /home/pi/scripts/klipper_config_git_backup.sh
```

Now the changes you make in your config will be pushed to GitHub everytime you power on your printer.

## Further implementation

You can add the script to your macros in your `printer.cfg`. Just add the following lines to your macro section:

```shell
[gcode_shell_command backup_cfg]
command: sh /home/pi/scripts/klipper_config_git_backup.sh
timeout: 45.
verbose: True

[gcode_macro BACKUP_CFG]
gcode:
    RUN_SHELL_COMMAND CMD=backup_cfg
```
