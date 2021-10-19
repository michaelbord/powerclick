function Write-ProcessCfg {
    param (
        $Processes
    )
    
    $Processes | ConvertTo-Json | Set-Content -Path ".\process.cfg"
}

function  Write-DefaultProcessCfg {
    $processes = @(0, 0) 
    Write-ProcessCfg -Processes $processes
}

function Read-ProcessCfg {    
    return Get-Content -Path ".\process.cfg" -Raw | ConvertFrom-Json
}


if (-not (Test-Path -Path ".\process.cfg")) {
    Write-Host "process.cfg not found."
    Write-DefaultProcessCfg
}

try {
    $processes = Read-ProcessCfg
}
catch {
    Write-Host "process.cfg not valid"
    Write-DefaultProcessCfg
    $processes = Read-ProcessCfg
}

if (@(Get-Process -Name powershell | Where-Object -FilterScript { $_.Id -eq $processes[0] }).Count -eq 0) {
    $process1 = Start-Process powershell -ArgumentList .\Never-Stop1.ps1 -PassThru
    Write-Host "Start process 1: $($process1.Id)"
    $processes[0] = $process1.Id
} else {
    Write-Host "Process 1 already running: $($process1.Id)"
}

if (@(Get-Process -Name powershell | Where-Object -FilterScript { $_.Id -eq $processes[1] }).Count -eq 0) {
    $process2 = Start-Process powershell -ArgumentList .\Never-Stop2.ps1 -PassThru
    Write-Host "Start process 2: $($process2.Id)"
    $processes[1] = $process2.Id
} else {
    Write-Host "Process 2 already running: $($process2.Id)"
}

Write-ProcessCfg -Processes $processes
