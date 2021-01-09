# emask-notifier

## Introduction

Using the Nexmo API to make SMS message with specific phone number and user.

## Emask Notifier Installation (Deprecated)

- Set up a Nexmo account on [Nexmo developer site](https://dashboard.nexmo.com/)
- Creating `phone.csv` and locate this CSV file is with `emask-notifier.sh` on same directory.

And the format is as follows:
```
user_name,user_phone
```
- Set `api_key` as a system environment variable with `echo 'export api_key="{your_api_key}"' | sudo tee -a /etc/environment` on `/etc/environment` file
- Set `api_secret` as a system environment variable with `echo 'export api_secret="{your_api_secret}"' | sudo tee -a /etc/environment` on `/etc/environment` file
- Using `cd /path/to/emask-notifier/ && ./emask-notifier.sh` as a Cronjob to let this Bash script do work automatically.
- Done. Happy to do notification for your friends :)!

## Emask Notifier Uninstallation (Deprecated)

- Remove `api_key` system environment variable on `/etc/environment` file
- Remove `api_secret` system environment variable on `/etc/environment` file
- Remove this Cronjob work.

## Emask Notifier for notifier.php Installation

- Checking the `supervisor`, `curl` and `cron` commands have been available on deployed operating system.
- `PHP 7.4` has been installed on Ubuntu operating system.
- Download `composer.phar` with `curl -sS https://getcomposer.org/installer | php7.4` command.
- Running `php composer.phar update -n` command.
- Creating the `.env` to setup the `VONAGE_API_KEY` and `VONAGE_API_SECRET` variables.
- Creating the `phone.csv` to setup the user phone number lists.
- Running the `notifier_php_builder.sh` script to setup all of above works.

## Emask Notifier for notifier.php Uninstallation

- We assume that this uninstallation work is running with non-root user.
- Stopping notifier worker with `sudo rm /etc/supervisor/conf.d/notifier-php.conf`
- Restarting supervisor service with `sudo systemctl restart supervisor`
- Removing this repository with `rm -rf /path/to/emask-notifier`
