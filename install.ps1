param(
    [string]$InstallRoot = 'C:\ADS'
)
$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $remoteScript = 'https://raw.githubusercontent.com/g4348914-coder/ads-suite-install/main/install.ps1'
    $command = "& ([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing '$remoteScript').Content))"
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $command
    ) | Out-Null
    exit
}

$AssetName = 'ADS-Suite-FIXED-20261112.zip'
$AssetUrl = "https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log2/$AssetName"
$ExpectedHash = '7F20B93F65A424B03E07D1B57F41F506D3781946920E3757DB8F477EF2D1A5CF'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path $InstallRoot)) { New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null }
$Work = Join-Path $InstallRoot 'update'
New-Item -ItemType Directory -Path $Work -Force | Out-Null
$Zip = Join-Path $Work $AssetName
$Stage = Join-Path $Work 'stage'

$running = Get-CimInstance Win32_Process -Filter "Name='ADS Monitor.exe'" -ErrorAction SilentlyContinue | Select-Object -First 1
$App = Join-Path $InstallRoot 'ADS-Suite'
if ($running -and $running.ExecutablePath) {
    $App = Split-Path $running.ExecutablePath -Parent
} elseif (Test-Path (Join-Path $InstallRoot 'ADS Monitor.exe')) {
    $App = $InstallRoot
}
Write-Host "ADS Suite path: $App"

$backupRoot = Join-Path (Split-Path $InstallRoot -Parent) ("ADS-backup-$Stamp")
if (Test-Path $App) {
    Write-Host "Backup: $backupRoot"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    robocopy $App $backupRoot /E /XD $Work /NFL /NDL /NJH /NJS | Out-Null
    if ($LASTEXITCODE -gt 7) { throw "Backup failed: robocopy $LASTEXITCODE" }
}

$tasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -like '*ADS*' })
foreach ($task in $tasks) {
    try { Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue | Out-Null } catch {}
}
Get-Process 'ADS Monitor' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

try {
    Write-Host "Downloading $AssetName ..."
    $needDownload = -not (Test-Path $Zip)
    if (-not $needDownload) {
        $actual = (Get-FileHash $Zip -Algorithm SHA256).Hash
        $needDownload = $actual -ne $ExpectedHash
    }
    if ($needDownload) {
        if (Test-Path $Zip) { Remove-Item $Zip -Force }
        Invoke-WebRequest -Uri $AssetUrl -OutFile $Zip -UseBasicParsing
    }
    $actual = (Get-FileHash $Zip -Algorithm SHA256).Hash
    if ($actual -ne $ExpectedHash) { throw "Bad archive hash: $actual" }

    Remove-Item $Stage -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'Extracting...'
    Expand-Archive -Path $Zip -DestinationPath $Stage -Force
    $source = Join-Path $Stage 'ADS-Suite'
    if (-not (Test-Path (Join-Path $source 'ADS Monitor.exe'))) { throw 'ADS Monitor.exe not found in archive' }
    New-Item -ItemType Directory -Path $App -Force | Out-Null
    Write-Host "Installing to $App ..."
    robocopy $source $App /E /XF "*.log" /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
    if ($LASTEXITCODE -gt 7) { throw "Install copy failed: robocopy $LASTEXITCODE" }

    $openLog = Join-Path $Stage 'open-system-log.cmd'
    if (Test-Path $openLog) { Copy-Item $openLog (Join-Path $App 'open-system-log.cmd') -Force }

    $cf = Join-Path $Stage 'cloudflared.exe'
    $cfTarget = Join-Path $InstallRoot 'cloudflared.exe'
    if ((Test-Path $cf) -and -not (Test-Path $cfTarget)) { Copy-Item $cf $cfTarget -Force }

    foreach ($task in $tasks) {
        try { Enable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue | Out-Null } catch {}
    }

    Start-Process -FilePath (Join-Path $App 'ADS Monitor.exe') -WorkingDirectory $App | Out-Null
    Start-Sleep -Seconds 5
    Write-Host 'Installed and started.'
    Write-Host "System log: $(Join-Path $App 'system.log')"
    Write-Host "Open log:   $(Join-Path $App 'open-system-log.cmd')"
} catch {
    foreach ($task in $tasks) {
        try { Enable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue | Out-Null } catch {}
    }
    Write-Error $_
    exit 1
}
