# emask-notifier

## Introduction

Using the Nexmo API to make SMS message with specific phone number and user.

## Installation

- Set up a Nexmo account on (Nexmo developer site)[https://dashboard.nexmo.com/]
- Creating `phone.csv` and locate this CSV file is with `emask-notifier.sh` on same directory
And the format is as follows:
```
user_name,user_phone
```
- Set `api_key` environment variable with `export api_key={your_api_key}`
- Set `api_secret` environment variable with `export api_secret={your_api_secret}`
- Set Cronjob to let this Bash script do work automatically.
