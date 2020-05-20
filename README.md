# emask-notifier

## Introduction

Using the Nexmo API to make SMS message with specific phone number and user.

## Installation

- Set up a Nexmo account on [Nexmo developer site](https://dashboard.nexmo.com/)
- Creating `phone.csv` and locate this CSV file is with `emask-notifier.sh` on same directory
And the format is as follows:
```
user_name,user_phone
```
- Set `api_key` as a system environment variable with `echo 'export api_key="{your_api_key}"' | sudo tee -a /etc/environment` on `/etc/environment` file
- Set `api_secret` as a system environment variable with `echo 'export api_secret="{your_api_secret}"' | sudo tee -a /etc/environment` on `/etc/environment` file
- Using `cd /path/to/emask-notifier/ && ./emask-notifier.sh` as a Cronjob to let this Bash script do work automatically.
- Done. Happy to do notification for your friends :)!

## Uninstallation

- Remove `api_key` system environment variable on `/etc/environment` file
- Remove `api_secret` system environment variable on `/etc/environment` file
- Remove this Cronjob work.
