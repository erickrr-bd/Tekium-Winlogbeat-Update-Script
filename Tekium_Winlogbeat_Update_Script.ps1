<#
.Description
PowerShell script that installs/updates Winlogbeat via DC and WinRM.
.PARAMETER hosts_file
Name of the file with the list of hosts.
.EXAMPLE
PS> .\Tekium_Winlogbeat_Updgrade_Script.ps1 -hosts_file "hosts_file_update.txt"
.SYNOPSIS
PowerShell script that installs/updates the Winlogbeat agent via DC.
#>
Param([string] $hosts_file = "hosts_update.txt")
Clear-Host

$date = Get-Date -Format "yyyy_MM_dd"
$log = "winlogbeat_update_$date.log"

Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-host -Object "Copyright©Tekium 2024. All rights reserved." -ForegroundColor green
Write-host -Object "Author: Erick Roberto Rodríguez Rodríguez" -ForegroundColor green
Write-host -Object "Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" -ForegroundColor green
Write-Host -Object "GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script" -ForegroundColor green
Write-host -Object "Tekium-Winlogbeat-Update-Script v1.4.1 - May 2024" -ForegroundColor green
Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-Output -InputObject "`nExecution start date: $(Get-Date)"
Write-Output -InputObject "Hosts File: $hosts_file`n"

"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append
"Copyright©Tekium 2024. All rights reserved." | Out-File -FilePath $log -Append
"Author: Erick Roberto Rodríguez Rodríguez" | Out-File -FilePath $log -Append
"Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" | Out-File -FilePath $log -Append
"GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script" | Out-File -FilePath $log -Append
"Tekium-Winlogbeat-Upgrade-Script v1.4.1 - May 2024" | Out-File -FilePath $log -Append
"-------------------------------------------------------------------------------------" | Out-File -FilePath $log -Append
"`nExecution start date: $(Get-Date)" | Out-File -FilePath $log -Append
"Hosts File: $hosts_file`n" | Out-File -FilePath $log -Append

$hosts_list = Get-Content -Path $hosts_file -ErrorAction SilentlyContinue -ErrorVariable Err
if(-not $?){
    Write-Host -Object "`nFile not found: $hosts_file" -ForegroundColor Red
    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
}
else{
    Write-Host -Object "`nFile found: $hosts_file" -ForegroundColor Green
    (Get-Date).ToString() + " INFO - File found: $hosts_file" | Out-File -FilePath $log -Append
    foreach($hostname in $hosts_list){
        Write-Output -InputObject "`nServer: $hostname"
        Write-Output -InputObject "`nValidating connection via WinRM with the server: $hostname"
        $winrm_validation = Test-WSMan -ComputerName $hostname -ErrorAction SilentlyContinue -ErrorVariable Err
        if($winrm_validation){
            Write-Host -Object "`nConnection established with the server: $hostname" -ForegroundColor Green
            (Get-Date).ToString() + " INFO - Connection established with the server: $hostname" | Out-File -FilePath $log -Append
            Write-Output -InputObject "`nValidating Winlogbeat service on server: $hostname"
            $winlogbeat_service = Get-Service -ComputerName $hostname -Name winlogbeat -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_service){
                Write-Host -Object "`nWinlogbeat's service exists on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's service exists on server: $hostname" | Out-File -FilePath $log -Append
                $service_status = (Get-Service -Name "winlogbeat" -ComputerName $hostname).status
                Write-Output -InputObject "`nWinlogbeat's service is $service_status on server: $hostname"
                Write-Output -InputObject "`nStopping Winlogbeat service on server: $hostname"
                Invoke-Command -ComputerName $hostname -ScriptBlock{
                    Stop-Service -Name "winlogbeat" -Force
                    Start-Sleep -Seconds 2
                    $service_status = (Get-Service -Name "winlogbeat").status
                    if($service_status -ne "Stopped"){
                        Write-Host -Object "`nKilling Winlogbeat's service on server: $env:computerName" -ForegroundColor White
                        $service_pid = (get-wmiobject win32_service | where { $_.name -eq 'winlogbeat'}).processId
                        taskkill /pid $service_pid /f    
                    }
                } -ErrorAction SilentlyContinue -ErrorVariable Err
                $service_status = (Get-Service -Name "winlogbeat" -ComputerName $hostname).status
                Write-Host -Object "`nWinlogbeat's service is $service_status on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat's service is $service_status on server: $hostname" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host -Object "`nWinlogbeat's service doesn't exist on server: $hostname" -ForegroundColor Yellow
                (Get-Date).ToString() + " WARNING - Winlogbeat's service doesn't exist on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " WARNING - $Err" | Out-File -FilePath $log -Append
                Write-Output -InputObject "`nCreating Winlogbeat's service on server: $hostname"
                Invoke-Command -ComputerName $hostname -ScriptBlock{
                    $workdir = "C:\Program Files\winlogbeat"
                    New-Service -name winlogbeat `
                        -displayName Winlogbeat `
                        -binaryPathName "`"$workdir\winlogbeat.exe`" --environment=windows_service -c `"$workdir\winlogbeat.yml`" --path.home `"$workdir`" --path.data `"$env:PROGRAMDATA\winlogbeat`" --path.logs `"$env:PROGRAMDATA\winlogbeat\logs`" -E logging.files.redirect_stderr=true"
                } -ErrorAction SilentlyContinue -ErrorVariable Err
                if(-not $Err){
                    Write-Host -Object "`nWinlogbeat's service created on server: $hostname" -ForegroundColor Green
                    (Get-Date).ToString() + " INFO - Winlogbeat's service created on server: $hostname" | Out-File -FilePath $log -Append
                }
                else{
                    Write-Host -Object "`nWinlogbeat's service not created on server: $hostname" -ForegroundColor Red
                    (Get-Date).ToString() + " ERROR - Winlogbeat's service not created on server: $hostname" | Out-File -FilePath $log -Append
                    (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                }
            }
            Write-Output -InputObject "`nValidating Winlogbeat installation on server: $hostname"
            $winlogbeat_path = "\\" + $hostname + "\c$\Program Files\winlogbeat"
            $program_files_path = "\\" + $hostname + "\c$\Program Files"
            if(Test-Path -Path $winlogbeat_path){
                Write-Host -Object "`nWinlogbeat found on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat found on server: $hostname" | Out-File -FilePath $log -Append
                $service_status = (Get-Service -Name "winlogbeat" -ComputerName $hostname).status
                if($service_status -eq "Stopped"){
                    Write-Output -InputObject "`nRemoving current Winlogbeat's version from server: $hostname"
                    Remove-Item -Path $winlogbeat_path -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable Err
                    if(-not $Err){
                        Write-Host -Object "`nWinlogbeat removed from server: $hostname" -ForegroundColor Green
                        (Get-Date).ToString() + " INFO - Winlogbeat removed from server: $hostname" | Out-File -FilePath $log -Append
                    }
                    else{
                        Write-Host -Object "`nWinlogbeat not removed on server: $hostname" -ForegroundColor Red
                        (Get-Date).ToString() + " ERROR - Winlogbeat not removed on server: $hostname" | Out-File -FilePath $log -Append
                        (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
                    }
                }
                else{
                    Write-Host -Object "`nWinlogbeat's service isn't stopped on server: $hostname" -ForegroundColor Red
                }
            }
            else{
                Write-Host -Object "`nWinlogbeat not found on server: $hostname" -ForegroundColor Yellow
                (Get-Date).ToString() + " WARNING - Winlogbeat not found on server: $hostname" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "`nInstalling/Updating Winlogbeat on the server: $hostname"
            Copy-Item -Path "winlogbeat" -Destination $program_files_path -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable Err
            if(-not $Err){
                Write-Host -Object "`nWinlogbeat installed/updated on server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " INFO - Winlogbeat installed/updated on server: $hostname" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host -Object "`nWinlogbeat not installed/updated on server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " ERROR - Winlogbeat not installed/updated on server: $hostname" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
            }
            Write-Output -InputObject "`nStarting Winlogbeat service on server: $hostname"
            Invoke-Command -ComputerName $hostname -ScriptBlock{
                Start-Service -Name "winlogbeat"
                Start-Sleep -Seconds 2
            } -ErrorAction SilentlyContinue -ErrorVariable Err
            $service_status = (Get-Service -Name "winlogbeat" -ComputerName $hostname).status
            if ($service_status -eq "Running"){
                Write-Host -Object "`nWinlogbeat's service is $service_status on server: $hostname" -ForegroundColor Green
            }
            else{
                Write-Host -Object "`nWinlogbeat's service is $service_status on server: $hostname" -ForegroundColor Red   
            }
            (Get-Date).ToString() + " INFO - Winlogbeat's service is $service_status on server: $hostname" | Out-File -FilePath $log -Append
        }
        else{
            Write-Host -Object "`nFailed to connect to server: $hostname" -ForegroundColor Red
            (Get-Date).ToString() + " ERROR - Failed to connect to server: $hostname" | Out-File -FilePath $log -Append
            (Get-Date).ToString() + " ERROR - $Err" | Out-File -FilePath $log -Append
        }
    }
}
Write-Output -InputObject "`nExecution end date: $(Get-Date)"
"`nExecution end date: $(Get-Date)" | Out-File -FilePath $log -Append