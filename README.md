# truenas-scripts
drivetemp.zsh is a script I wrote to pull temperatures from all hard drives on the system and display device block name, serial number & current temps of the system you can set the max temperature you want to be displayed in red flashing text. I wrote this so I can periodically check all my drives temps so I know where there may be a fan not working properly or being obstructed.

db_backup.zsh is based off a script I found on TrueNAS forums years ago to make daily backups of the freenas_v1.db. I tweaked it to my needs.

db_check.zsh is based off a script I found on TrueNAS forums years ago to check the freenas_v1.db of corruption. It will email me if corruption is found and include a copy of the test results, so I can restore a backup.
