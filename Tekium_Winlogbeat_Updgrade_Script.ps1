<#
.Description
The script updates the Winlogbeat agent using the domain controller and the winRM service.
.PARAMETER hosts_file_name
Name of the TXT file that contains the names of the Windows servers where Winlogbeat will be updated.
It is an optional value.
.EXAMPLE
PS> .\Tekium_Winlogbeat_Updgrade_Script.ps1 -hosts_file_name "hosts_file_update.txt"
.SYNOPSIS
Powershell script to update Winlogbeat on Windows systems.
#>
Param([string] $hosts_file_name = "hosts_update.txt")
Clear-Host

$current_date = Get-Date -Format "yyyy_MM_dd"
$log_file_name = "winlogbeat_update_$current_date.log"

Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-host -Object "Copyright©Tekium 2023. All rights reserved." -ForegroundColor green
Write-host -Object "Author: Erick Roberto Rodríguez Rodríguez" -ForegroundColor green
Write-host -Object "Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" -ForegroundColor green
Write-Host -Object "GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script" -ForegroundColor green
Write-host -Object "Tekium Winlogbeat Upgrade Script v1.3 - September 2023" -ForegroundColor green
Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-Output -InputObject "Hosts File Name: $hosts_file_name`n"

$hosts_list = Get-Content -Path $hosts_file_name -ErrorAction SilentlyContinue -ErrorVariable Err
if(-not $?){
    Write-Host -Object "`nFile not found: $hosts_file_name" -ForegroundColor Red
    (Get-Date).ToString() + " Error: $Err[0]" | Out-File -FilePath $log_file_name -Append
}
else{
    "-------------------------------------------------------------------------------------" | Out-File -FilePath $log_file_name -Append
    "Copyright©Tekium 2023. All rights reserved." | Out-File -FilePath $log_file_name -Append
    "Author: Erick Roberto Rodríguez Rodríguez" | Out-File -FilePath $log_file_name -Append
    "Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" | Out-File -FilePath $log_file_name -Append
    "GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script" | Out-File -FilePath $log_file_name -Append
    "Tekium Winlogbeat Upgrade Script v1.3 - September 2023" | Out-File -FilePath $log_file_name -Append
    "-------------------------------------------------------------------------------------" | Out-File -FilePath $log_file_name -Append
    "Hosts File Name: $hosts_file_name" | Out-File -FilePath $log_file_name -Append
    foreach($hostname in $hosts_list){
        $winrm_validation = Test-WSMan -ComputerName $hostname -ErrorAction SilentlyContinue -ErrorVariable Err
        if($winrm_validation){
            Write-Host -Object "`nConnection established with the server: $hostname" -ForegroundColor Green
            (Get-Date).ToString() + " Connection established with the server: $hostname" | Out-File -FilePath $log_file_name -Append
            Start-Sleep -s 2
            $winlogbeat_service = Get-Service -ComputerName $hostname -Name winlogbeat -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_service){
                Write-Host -Object "`nStopping winlogbeat service on the server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " Stopping winlogbeat service on the server: $hostname" | Out-File -FilePath $log_file_name -Append
                Start-Sleep -s 2
                $winlogbeat_service | Set-Service -Status Stopped
                Start-Sleep -s 2
                $winlogbeat_service_status = $winlogbeat_service.status
                Write-Host -Object "`nWinlogbeat service status: $winlogbeat_service_status on server $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " Winlogbeat service status: $winlogbeat_service_status on server $hostname" | Out-File -FilePath $log_file_name -Append
            }
            else{
                Write-Host -Object "`nWinlogeat service not found on server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " Winlogeat service not found on server: $hostname" | Out-File -FilePath $log_file_name -Append
                (Get-Date).ToString() + " Error: $Err[0]" | Out-File -FilePath $log_file_name -Append
                Start-Sleep -s 2
                Write-Host -Object "`nCreating Winlogbeat service on the server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " Creating Winlogbeat service on the server: $hostname" | Out-File -FilePath $log_file_name -Append
                Start-Sleep -s 2
                Invoke-Command -ComputerName $hostname -ScriptBlock{
                    $workdir = "C:\Program Files\winlogbeat"
	                New-Service -name winlogbeat `
                        -displayName Winlogbeat `
                        -binaryPathName "`"$workdir\winlogbeat.exe`" --environment=windows_service -c `"$workdir\winlogbeat.yml`" --path.home `"$workdir`" --path.data `"$env:PROGRAMDATA\winlogbeat`" --path.logs `"$env:PROGRAMDATA\winlogbeat\logs`" -E logging.files.redirect_stderr=true"
                } -ErrorAction SilentlyContinue -ErrorVariable Err
                if($Err){
	                Write-Host -Object "`nWinlogbeat service not created on server: $hostname" -ForegroundColor Red
                    (Get-Date).ToString() + " Winlogbeat service not created on server: $hostname" | Out-File -FilePath $log_file_name -Append
	                (Get-Date).ToString() + " Error: $Err" | Out-File -FilePath $log_file_name -Append
                }
                else{
                    Write-Host -Object "`nWinlogbeat service created on the server: $hostname" -ForegroundColor Green
                    (Get-Date).ToString() + " Winlogbeat service created on server: $hostname" | Out-File -FilePath $log_file_name -Append
                }

            }
            Start-Sleep -s 2
            $winlogbeat_path = "\\" + $hostname + "\c$\Program Files\winlogbeat"
            $program_files_path = "\\" + $hostname + "\c$\Program Files"
            if(Test-Path $winlogbeat_path){
                Write-Host -Object "`nPrevious version of Winlogbeat found on the server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " Previous version of Winlogbeat found on the server: $hostname" | Out-File -FilePath $log_file_name -Append
                Start-Sleep -s 2
                Remove-Item $winlogbeat_path -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable Err
                Start-Sleep -s 2
                if(-not $?){
                    Write-Host -Object "`nCurrent winlogbeat not deleted on server: $hostname" -ForegroundColor Red
                    (Get-Date).ToString() + " Current winlogbeat not deleted on server: $hostname" | Out-File -FilePath $log_file_name -Append
                    (Get-Date).ToString() + " Error: $Err[0]" | Out-File -FilePath $log_file_name -Append
                }
                else{
                    Write-Host -Object "`nCurrent winlogbeat deleted on server: $hostname" -ForegroundColor Green
                    (Get-Date).ToString() + " Current winlogbeat deleted on server: $hostname" | Out-File -FilePath $log_file_name -Append
                }
            }
            Start-Sleep -s 2
            Write-Host -Object "`nCopying new version of Winlogbeat to the server: $hostname" -ForegroundColor Green
            (Get-Date).ToString() + " Copying new version of Winlogbeat to the server: $hostname" | Out-File -FilePath $log_file_name -Append
            Start-Sleep -s 2
            Copy-Item -Path "winlogbeat" -Destination $program_files_path -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable Err
            Start-Sleep -s 2
            if(-not $?){
                Write-Host -Object "`nWinlogbeat not copied to server: $hostname" -ForegroundColor Red
                (Get-Date).ToString() + " Winlogbeat not copied to server: $hostname" | Out-File -FilePath $log_file_name -Append
                (Get-Date).ToString() + " Error: $Err[0]" | Out-File -FilePath $log_file_name -Append
            }
            else{
                Write-Host -Object "`nWinlogbeat copied to server: $hostname" -ForegroundColor Green
                (Get-Date).ToString() + " Winlogbeat copied to server: $hostname" | Out-File -FilePath $log_file_name -Append
            }
            Start-Sleep -s 2
            Write-Host -Object "`nStarting the Winlogbeat service on the server: $hostname" -ForegroundColor Green
            (Get-Date).ToString() + " Starting the Winlogbeat service on the server: $hostname" | Out-File -FilePath $log_file_name -Append
            Start-Sleep -s 2
            $winlogbeat_service | Set-Service -Status Running
            Start-Sleep -s 2
            $winlogbeat_service_status = $winlogbeat_service.status
            Write-Host -Object "`nWinlogbeat service status: $winlogbeat_service_status on server $hostname`n" -ForegroundColor Green
            (Get-Date).ToString() + " Winlogbeat service status: $winlogbeat_service_status on server $hostname" | Out-File -FilePath $log_file_name -Append
        }
        else{
            Write-Host -Object "`nFailed to connect to server: $hostname" -ForegroundColor Red
            (Get-Date).ToString() + " Failed to connect to server: $hostname" | Out-File -FilePath $log_file_name -Append
           (Get-Date).ToString() + " Error: $Err[0]" | Out-File -FilePath $log_file_name -Append
        }
    }
}