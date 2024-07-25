# KGB - Klipper Git Backup

Securing your printer.cfg

## Instructions

KGB automatically backs up your klipper config to GitHub. All you have to do is configure it through the UI, run the installer and you're done.

Detailed instructions an documentation can be found in the docs folder [here](docs/DOCUMENTATION.md).

### Quick start

* **Step 1:**

  Create an access token for the script to use:

  Navigate to `Profile > Settings > Developer settings > Personal access tokens > Fine-grained tokens`.

  There you'll have to create a new fine-grained access token, so the script will be able to create your repo and add the SSH key to your profile.

  The following permissions are required:
  
  | Section                | Permission       | Setting      |
  |------------------------|------------------|--------------|
  | Repository Access      | All Repositories |              |
  | Repository Permissions | Admin            | read & write |
  | Account Permissions    | Git SSH Keys     | read & write |
  | Account Permissions    | SSH Signing Keys | read         |

  Copy the access token and save it on your Pi:
  ```bash
  mkdir ~/.secrets && chmod 700 ~./secrets
  nano ~/.secrets/gh-token && chmod 600 ~/.secrets/gh-token
  ```

  Paste the access token, save and quit the editor (`Ctrl + x`, `y` to confirm). The hard part is done now.

  Detailed information on how to create the token can be found [here](/docs/all/SETUP.md).

* **Step 2:**

  Make sure you have `git` installed:
  ```bash
  sudo apt-get install git -y
  ```

* **Step 3:**

  Download KGB:
  ```bash
  cd ~ && git clone https://github.com/Low-Frequency/Klipper-Git-Backup.git
  ```

* **Step 4:**

  Start KGB:
  ```bash
  chmod +x ~/Klipper-Git-Backup/*.sh && ./Klipper-Git-Backup/kgb.sh
  ```

* **Step 5:**

  You should now be in the main menu:

  ![Main menu](/docs/images/readme/main_menu.png)

  Choose what you want to do by entering the numer of the displayed action into the prompt. You should at least configure your GitHub username, your mail, the repository and one config folder before the install.

# How does it work?

This script runs when your Pi starts, or - if configured accordingly - on a set timeschedule. It waits for network connection and then pushes a backup to your specified location. Every action is logged. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes :wink:

# Further setup infos

## Checking the status of the utility

The utility runs as systemd timer. To view the current status you can execute `systemctl list-timers kgb`. This tells you when the next execution of the script is scheduled and when the last successful execution was.

# Credits

Big thanks to [KIAUH](https://github.com/th33xitus/kiauh) for the inspiration for the UI.
