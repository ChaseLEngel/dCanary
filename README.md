# dCanary - A disk utilization watcher
### Description
Uses df command to check a disk's percentage used and compares it with the limit set in the config file. If a disk is over the limit a [Telegram](https://telegram.org/) message is sent.
### Config
- telegram_api_token: [Get one here](https://core.telegram.org/api)
- telegram_chat_id: User or Group 8-digit id
- disks: [disk]: [percent limit]
```
telegram_api_token: ABC
telegram_chat_id: 12345678
disks:
  /dev/disk1: 95
  /dev/disk2: 50 
 ```