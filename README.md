# truenas-scripts
drivetemp.zsh is a script I wrote to pull temperatures from all hard drives on the system and display device block name, serial number & current temps of the system. You can set the max temperature you want to be displayed in red flashing text. I wrote this so you can periodically check all my drives temps so you know where there may be a fan not working properly or being obstructed.

db_backup.zsh is based off a script I found on TrueNAS forums years ago to make daily backups of the TrueNAS config. This will backup freenas-v1.db and pwenc_secret in tar format that is uploadable through the gui. This script will need you to enter the full back path in the BAKDIR variable.

db_check.zsh is based off a script I found on TrueNAS forums years ago to check the freenas-v1.db of corruption. It will email you if corruption is found and include a copy of the test results, so you can restore a backup.
