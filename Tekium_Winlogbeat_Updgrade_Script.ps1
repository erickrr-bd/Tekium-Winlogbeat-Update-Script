Param([string] $hosts_file_path = "C:\")
Clear-Host

$dir_actual = (pwd).ToString()
$file_hosts = $dir_actual + "\hosts_update.txt"
$log = $dir_actual + "\tekium_winlog_upgrade_script_log.log"
$from = $dir_actual + "\winlogbeat"

Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
write-host -Object "Copyright©Tekium 2023. All rights reserved." -ForegroundColor green
write-host -Object "Author: Erick Roberto Rodríguez Rodríguez" -ForegroundColor green
write-host -Object "Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com" -ForegroundColor green
Write-Host -Object "GitHub: https://github.com/erickrr-bd/Tekium-PAN-Hunter-Script" -ForegroundColor green
write-host -Object "Tekium Winlogbeat Upgrade Script v1.3 - September 2023" -ForegroundColor green
Write-Host -Object "-------------------------------------------------------------------------------------" -ForegroundColor Yellow
Write-Output -InputObject "Hosts File Path: $hosts_file_path`n"

$hosts_list_to_update = Get-Content hosts_file_path

foreach($host_to_update in $hosts_list_to_update){
    
}

<#
foreach($host_update in $list_hosts_update){
     $flag_service = 0
     $flag_directory = 0
     $flag_copy = 0
     $flag_not_winlog = 0
     $flag_winlog = 0
     $winrm_validation = Test-WSMan -ComputerName $host_update -ErrorAction SilentlyContinue -ErrorVariable Err
     $winlogbeat_service = Get-Service -ComputerName $host_update winlogbeat -ErrorAction SilentlyContinue -ErrorVariable Err
     $path_winlogbeat = '\\' + $host_update + '\c$\Program Files\winlogbeat'
     $to_path = '\\' + $host_update + '\c$\Program Files'
     if($winrm_validation){
        Write-Host "`nConnection established with the computer: $host_update" -ForegroundColor Green
        (Get-Date).ToString() + " " + "Connection established with the computer: $host_update" | Out-File -FilePath $log -Append
        if($winlogbeat_service){
            Write-Host "`nStopping winlogbeat service on the computer: $host_update" -ForegroundColor Green
            (Get-Date).ToString() + " " + "Stopping winlogbeat service on the computer: $host_update" | Out-File -FilePath $log -Append
            $winlogbeat_service | Set-Service -Status Stopped
            Start-Sleep -s 5
            $status_service_stop = $winlogbeat_service.status
            Write-Host "`nCurrent status of the Winlogbeat service on the computer: $host_update" -ForegroundColor Green
            (Get-Date).ToString() + " " + "Current status of the Winlogbeat service on the computer: $host_update" | Out-File -FilePath $log -Append
            Write-Host "Winlogbeat service status: $status_service_stop" -ForegroundColor Yellow
            (Get-Date).ToString() + " " + "Winlogbeat service status: $status_service_stop" | Out-File -FilePath $log -Append
            if($status_service_stop -like "Stopped"){
                $flag_service = 1
            }
            $flag_winlog = 1
        }
        else{
            $flag_service = 1
            $flag_not_winlog = 1
             Write-Host "`nWinlogbeat service not found on the computer: $host_update" -ForegroundColor Red
            (Get-Date).ToString() + " " + "Winlogbeat service not found on the computer: $host_update" | Out-File -FilePath $log -Append
            (Get-Date).ToString() + " " + "Error: $Err[0]" | Out-File -FilePath $log -Append
            Start-Sleep -s 5
        }
        if($flag_service -eq 1){
            if(Test-Path $path_winlogbeat){
                Remove-Item $path_winlogbeat -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable Err
                Start-Sleep -s 5
                if(-not $?){
                    Write-Host "`nError removing the previous version of Winlogbeat on the computer: $host_update" -ForegroundColor Red
                    (Get-Date).ToString() + " " + "Error removing the previous version of Winlogbeat on the computer: $host_update" | Out-File -FilePath $log -Append
                    (Get-Date).ToString() + " " + "Error: $Err[0]" | Out-File -FilePath $log -Append
                }
                else{
                    $flag_directory = 1
                    Write-Host "`nPrevious version of Winlogbeat removed on the computer: $host_update" -ForegroundColor Green
                    (Get-Date).ToString() + " " + "Previous version of Winlogbeat removed on the computer: $host_update" | Out-File -FilePath $log -Append
                }
            }
            else{
                $flag_directory = 1
                Write-Host "`nThe Winlogbeat directory was not found on the computer: $host_update" -ForegroundColor Red
                (Get-Date).ToString() + " " + "The Winlogbeat directory was not found on the computer: $host_update" | Out-File -FilePath $log -Append
            }
        }
        if($flag_directory -eq 1){
            Copy-Item -Path $from -Destination $to_path -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable Err
            Start-Sleep -s 5
            if(-not $?){
                Write-Host "`nError copying new version of Winlogbeat on the computer: $host_update" -ForegroundColor Red
                (Get-Date).ToString() + " " + "Error copying new version of Winlogbeat on the computer: $host_update" | Out-File -FilePath $log -Append
                (Get-Date).ToString() + " " + "Error: $Err[0]" | Out-File -FilePath $log -Append
            }
            else{
                $flag_copy = 1
                Write-Host "`nNew version of Winlogbeat installed on the computer: $host_update" -ForegroundColor Green
                (Get-Date).ToString() + " " + "New version of Winlogbeat installed on the computer: $host_update" | Out-File -FilePath $log -Append
            }
        }
        if($flag_copy -eq 1 -and $flag_not_winlog -eq 1){
            Write-Host "`nCreating the Winlogbeat service on the computer: $host_update" -ForegroundColor Green
            (Get-Date).ToString() + " " + "Creating the Winlogbeat service on the computer: $host_update" | Out-File -FilePath $log -Append
            Invoke-Command -ComputerName $host_update -ScriptBlock{
                $workdir = "C:\Program Files\winlogbeat"
	            New-Service -name winlogbeat `
                    -displayName Winlogbeat `
                    -binaryPathName "`"$workdir\winlogbeat.exe`" --environment=windows_service -c `"$workdir\winlogbeat.yml`" --path.home `"$workdir`" --path.data `"$env:PROGRAMDATA\winlogbeat`" --path.logs `"$env:PROGRAMDATA\winlogbeat\logs`" -E logging.files.redirect_stderr=true"
            } -ErrorAction SilentlyContinue -ErrorVariable Err
            if($Err){
	            write-host "Error: $Err" -ForegroundColor Red
	            (Get-Date).ToString() + " " + "Error: $Err" | Out-File -FilePath $log -Append
            }
            $winlogbeat_service = Get-Service -ComputerName $host_update winlogbeat -ErrorAction SilentlyContinue -ErrorVariable Err
            if($winlogbeat_service){
                $flag_winlog = 1
                Write-Host "`nWinlogbeat service created on the computer: $host_update" -ForegroundColor Green
                (Get-Date).ToString() + " " + "Winlogbeat service created on the computer: $host_update" | Out-File -FilePath $log -Append
            }
            else{
                Write-Host "`nError creating Winlogbeat service on computer: $host_update" -ForegroundColor Red
                (Get-Date).ToString() + " " + "Error creating Winlogbeat service on computer: $host_update" | Out-File -FilePath $log -Append
            }
        }
        if($flag_winlog -eq 1){
            Write-Host "`nStarting Winlogbeat service on the computer: $host_update" -ForegroundColor Green
            (Get-Date).ToString() + " " + "Starting Winlogbeat service on the computer: $host_update" | Out-File -FilePath $log -Append
            $winlogbeat_service | Set-Service -Status Running
            Start-Sleep -s 5
            $status_service_start = $winlogbeat_service.status
            Write-Host "`nCurrent status of the Winlogbeat service on the computer: $host_update" -ForegroundColor Green
            (Get-Date).ToString() + " " + "Current status of the Winlogbeat service on the computer: $host_update" | Out-File -FilePath $log -Append
            Write-Host "Winlogbeat service status: $status_service_start" -ForegroundColor Yellow
            (Get-Date).ToString() + " " + "Winlogbeat service status: $status_service_start" | Out-File -FilePath $log -Append
        }
     }
     else{
        Write-Host "`nError connecting to the computer: $host_update" -ForegroundColor Red
        (Get-Date).ToString() + " " + "Error connecting to the computer: $host_update" | Out-File -FilePath $log -Append
        (Get-Date).ToString() + " " + "Error: $Err[0]" | Out-File -FilePath $log -Append
        Start-Sleep -s 5 
     }
}
#>