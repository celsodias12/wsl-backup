# Wsl backup

This is a PowerShell script that allows you to back up a WSL (Windows Subsystem for Linux) distribution.

## Description

The script accepts the following parameters:

- -distroName: WSL distribution name that wants to backup.
- -backupType: (optional) Backup type to be performed (currently, only TAR is supported).
- -backupDir: Directory where the backup will be saved.
- -backupFileNamePrefix: (Optional) Prefix to be added to the backup file name.
- -backupSecondDir: (optional) directory to copy the backup file additionally.

## How to use

For example:

```shell
.\wsl-backup.ps1 -distroName "Ubuntu-22.04" -backupDir "E:\backup"
```

This will create a TAR file of the WSL distribution content called "Ubuntu-23.04" and save it in the directory E: \ Backup.

## Comments

The generated backup file will have a name based on the date and time of execution, with an optional prefix (if provided).
The script also supports the backup file copy to a second directory (optionally supplied) after creation of the TAR file.

## legal warning

The script is designed for backup purposes and can save important WSL distribution data. Be sure to understand the operation of the script and back up your important data before you execute it. The author is not responsible for any data loss or problems caused by the use of this script. Use it at your own risk.
