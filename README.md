# KGB - Klipper Git Backup

Securing your printer.cfg

## Instructions

KGB automatically backs up your klipper config to GitHub. All you have to do is configure it through the UI, run the installer and you're done.

### Prerequisites

Create a GitHub account and create a new repo.

### Getting and using KGB

* **Step 1:**

  Make sure you have `git` installed:
  ```bash
  sudo apt-get install git -y
  ```

* **Step 2:**

  Download KGB:
  ```bash
  cd ~ && git clone https://github.com/Low-Frequency/Klipper-Git-Backup.git
  ```

* **Step 3:**

  Start KGB:
  ```bash
  chmod +x ~/Klipper-Git-Backup/*.sh && ./Klipper-Git-Backup/kgb.sh
  ```

* **Step 4:**

  You should now be in the main menu:

  ![Main menu](/docs/images/main_menu.png)

  Choose what you want to do by entering the numer of the displayed action into the prompt. You should at least configure your GitHub Username, your Mail, one repository and one config folder before the install.

# How does it work?

This script runs when your Pi starts, or if configured on a set timeschedule. It waits for network connection and then pushes a backup to your specified locations. Every action is logged. This way you always know what fails, or has failed in the past.

It even has log rotation implemented, so it doesn't eat up the precious space for your gcodes :wink:



It runs as a service

To stop the service run the command 
```bash 
systemctl stop kgb.service
```

To start the service run the command 
```bash
systemctl start kgb.service
```

To check the status of the service run the command 
```bash
systemctl status kgb.service
```

# Further setup infos

## Adding an SSH key to your GitHub account

The setup script tells you to copy a private key and add it to your GitHub account. To do this just navigate to your *profile* -> *settings* -> *SSH and GPG keys*, add a new key and paste the copied key.

# Credits

Big thanks to [KIAUH](https://github.com/th33xitus/kiauh) for the inspiration for the UI. 
