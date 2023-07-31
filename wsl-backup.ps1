param(
  [Parameter(Mandatory, ParameterSetName = "backupArgs")]
  [string] $distroName,

  [Parameter(Mandatory = $false, ParameterSetName = "backupArgs")]
  [string] $backupType = "tar",

  [Parameter(Mandatory, ParameterSetName = "backupArgs")]
  [string] $backupDir,

  [Parameter(Mandatory = $false, ParameterSetName = "backupArgs")]
  [string] $backupFileNamePrefix,

  [Parameter(Mandatory = $false, ParameterSetName = "backupArgs")]
  [string] $backupSecondDir
)

# enum START #############################################################################
enum Backup_types {
  tar
}

# enum END ###############################################################################

# functions START ########################################################################
function wslBackup([string] $distro, [string] $backup_type, [string] $dir, [string] $backup_file_name) {
  createDirIfNotExists $dir

  $backup_path = "$dir\$backup_file_name"

  try {
    switch ($backup_type) {
      "tar" {
        wsl.exe --export $distro $backup_path
      }
      default {
        Write-Host "`n Error while creating backup. Invalid backup type: $backup_type`n"
        exit 1
      }

    }
  }
  catch {
    Write-Host "`nError while creating backup. Error:`n"
    Write-Host $_

    exit 1
  }
}

function copyFile([string] $dir, [string] $file_name, [string] $destination_dir) {
  createDirIfNotExists $destination_dir

  [string] $location_path = "$dir\$file_name"
  [string] $destination_path = "$destination_dir\$file_name"

  try {
    Copy-Item $location_path -Destination $destination_path
  }
  catch {
    Write-Host "`nError while copying backup to directory $destination_path. Error:`n"
    Write-Host $_

    exit 1
  }
}

function createDirIfNotExists([string] $path) {
  if (-not (Test-Path $path)) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
  }
}

function checkifRunningOnWsl() {
  if (Get-Item -ErrorAction SilentlyContinue -Path env:\WSL_INTEROP) {
    Write-Host "`nPlease run this script on Windows.`n"

    return $false
  }

  return $true
}

function getFileNameWithPrefix([string] $file_name_prefix, [string] $backup_type) {
  [string] $backup_file_name = ""

  if ($file_name_prefix) {
    $backup_file_name = "$($file_name_prefix)_"
  }

  $backup_file_name += "$(Get-Date -f yyyy-MM-dd_HH-mm-ss).$backup_type"

  return $backup_file_name
}

function getSizeOfFile([string] $file_path) {
  $file = Get-Item $file_path

  [string] $file_size_formatted = ""

  if ($file.Length -gt 1GB) {
    $file_size_formatted = "{0:N2}" -f ($file.Length / 1GB) + " GB"
  }
  elseif ($file.Length -gt 1MB) {
    $file_size_formatted = "{0:N2}" -f ($file.Length / 1MB) + " MB"
  }
  else {
    $file_size_formatted = "{0:N2}" -f ($file.Length / 1KB) + " KB"
  }

  return $file_size_formatted
}

# functions END ##########################################################################

# main START #############################################################################
if ($backupType -ne $([Backup_types]::$backupType)) {
  Write-Host "`nInvalid backup type. Use these backup types: $([Backup_types]::GetValues([Backup_types]))`n"

  return
}

if ((checkifRunningOnWsl) -eq $false) {
  return
}

$backup_file_name = getFileNameWithPrefix $backupFileNamePrefix $backupType

wslBackup $distroName $backupType $backupDir $backup_file_name

$backup_file_size = getSizeOfFile "$backupDir$backup_file_name"

Write-Host "`nBackup created: $backupDir\$backup_file_name"
Write-Host "Backup size: $backup_file_size`n"

if ($backupSecondDir) {
  Write-Host "`nCopying backup to second directory...`n"

  copyFile $backupDir $backup_file_name $backupSecondDir

  Write-Host "`nSuccessfully copied backup to second directory.`n"
}

# main END ###############################################################################
