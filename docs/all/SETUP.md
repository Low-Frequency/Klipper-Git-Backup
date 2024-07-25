# Setup

The first step is to get the script. The following sections will lead you through the setup of the script and it's requirements.

## Creating a fine-grained access token

To make the installer as accessible and simple as possible, I opted to use a tool called [GitHub CLI](https://cli.github.com/). This tool is used to create the backup repository and add the generated SSH key to your account.
The script automatically installs all needed dependencies, so you don't have to worry about additional software. However you'll need to create a token to be used with this application, or the install will fail. This section will show you how to do this.

First click on your profile picture in the top right and navigate to your account **settings** on GitHub:

![Account settings](/docs/images/setup/account_settings.png)

Once there, select the **developer settings** on the bottom of the menu:

![Developer settings](/docs/images/setup/developer_settings.png)

From here select **Fine-grained tokens** from the **Personal access tokens** dropdown:

![Access tokens](/docs/images/setup/access_tokens.png)

Select **Generate new token** to configure the permissions on the access token:

![Create token](/docs/images/setup/create_token.png)

You'll have to confirm your login via 2FA, since the next step is giving this token access to your account and the permissions to control some parts of it.

Upon creating the token, you'll have to give it a name. Name it whatever you like, however be aware that you can't change this, so you might want to set the name to something related to KGB.
The token expiration also has to be configured. Since the token is only used during install and uninstall, feel free to set the expiration date to the next day. This way nothing can happen if you accidentally leak the token anywhere. However be aware that you have to create a new token for the uninstall if it has expired.

In the next step give the token access to all your repositories. This is necessary, since the script will create a new private repository and you'll need read/write access to all repos for that. Granting read access to all your repos also ensures that you don't try to create a repo with a name that is already taken. This part is handled by the script by checking for existing repos and comparing the names with the one configured in the script.

![Token access](/docs/images/setup/token_access.png)

Next up you'll have to configure the repository permissions for the token. Select **Administration** and give the token **read and write** permissions:

![Repo permission](/docs/images/setup/repo_permission.png)

The final permissions needed are in **Account permissions**. Give the token **read and write** permissions for **Git SSH keys** and **SSH signing keys**:

![Account permissions](/docs/images/setup/account_permissions.png)

The **SSH signing keys** permission is not strictly needed, but will prevent errors when uninstalling the script.

You should now see 2 permissions for all your repositories and 2 account permissions in the overview section of the site:

![Generate token](/docs/images/setup/generate_token.png)

Click on **Generate token** to finish the token setup.

You should now be on the overview page of your personal access tokens. Do **not** close this page, since the freshly created token will just be shown once! Copy the token and store it somwhere safe.

![Token overview](/docs/images/setup/token_overview.png)

To finalize the setup, connect to your Pi and save the newly created token in a file. The file has to be named `gh-token` and must be located in `~/.secrets`. To do this execute the following command on your Pi:
```bash
mkdir -p ~/.secrets
chmod 700 ~/.secrets
nano ~/.secrets/gh-token
chmod 600 ~/.secrets/gh-token
```

On the third command copy the token from GitHub and paste it into the terminal (right click to paste if you're using PuTTY). Save and exit the editor with `Ctrl + x`, confirm the prompt with `y` and you're done.

[Go back](/docs/DOCUMENTATION.md)

## Downloading the script

Downloading the script is pretty straight forward.

First you'll have to make sure that `git` is installed:
```bash
sudo apt-get install git -y
```

The second step is to download KGB:
```bash
cd ~ && git clone https://github.com/Low-Frequency/Klipper-Git-Backup.git
```

After that's done you can start KGB and configure it through the UI:
```bash
chmod +x ~/Klipper-Git-Backup/*.sh && ./Klipper-Git-Backup/kgb.sh
```

[Go back](/docs/DOCUMENTATION.md)
