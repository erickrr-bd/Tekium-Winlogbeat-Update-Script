# Tekium-Winlogbeat-Update-Script v1.3

It's a tool that updates the version of the Winlogbeat agent (Elastic) on Windows systems through the domain controller.

Born from the need to have a tool that is easy to run and use. Ideal if the automated and massive update of Winlogbeat is required in your organization.

# Characteristics
- Mass update of the Winlogbeat agent remotely using the domain controller
- Generate a log file with the update process described.

# Requirements
- Access to the domain controller.
- PowerShell (A recent version is recommended)
- PowerShell Console (Executed with administrator permissions)
- Script execution enabled (Otherwise, run `Set-ExecutionPolicy Unrestricted`)
- WinRM service enabled
- Port 5985 open

# Running

```
usage: ./Tekium_Winlogbeat_Updgrade_Script.ps1 [-hosts_file_name]

optional arguments:
  -hosts_file_name       Hostnames file name (default: hosts_update.txt)
```

By default, the script takes the hostnames from the "hosts_update.txt" file. Both the Winlogbeat folder and the file with the hostnames must be at the same directory level as the update script.

This can be changed using the parameters: "hosts_update.txt", where the name of the file from which the hostnames are read is indicated.

For example:

`.\Tekium_Winlogbeat_Updgrade_Script.ps1 -hosts_file_name “archivo_hostnames.txt"`

The structure of the file with the hostsnames must be the following. It is recommended to use hostnames instead of IP addresses, this way you avoid entering authentication credentials.

```
HOST1
HOST2
HOST3
HOSTWINDOWS
BDWINDOWS
DEVWINDOWS
```

# Example output

```
-------------------------------------------------------------------------------------
Copyright©Tekium 2023. All rights reserved.
Author: Erick Roberto Rodríguez Rodríguez
Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com
GitHub: https://github.com/erickrr-bd/Tekium-Winlogbeat-Update-Script
Tekium Winlogbeat Upgrade Script v1.3 - September 2023
-------------------------------------------------------------------------------------
Hosts File Name: hosts_update.txt
12/09/2023 06:25:59 p. m. Connection established with the server: HOST1
12/09/2023 06:26:01 p. m. Stopping winlogbeat service on the server: HOST1
12/09/2023 06:26:06 p. m. Winlogbeat service status: Stopped on server HOST1
12/09/2023 06:26:08 p. m. Previous version of Winlogbeat found on the server: HOST1
12/09/2023 06:26:13 p. m. Current winlogbeat deleted on server: HOST1
12/09/2023 06:26:15 p. m. Copying new version of Winlogbeat to the server: HOST1
12/09/2023 06:26:20 p. m. Winlogbeat copied to server: HOST1
12/09/2023 06:26:22 p. m. Starting the Winlogbeat service on the server: HOST1
12/09/2023 06:26:28 p. m. Winlogbeat service status: Running on server HOST1
```

# Commercial Support
![Tekium](https://github.com/unmanarc/uAuditAnalyzer2/blob/master/art/tekium_slogo.jpeg)

Tekium is a cybersecurity company specialized in red team and blue team activities based in Mexico, it has clients in the financial, telecom and retail sectors.

Tekium is an active sponsor of the project, and provides commercial support in the case you need it.

For integration with other platforms such as the Elastic stack, SIEMs, managed security providers in-house solutions, or for any other requests for extending current functionality that you wish to see included in future versions, please contact us: info at tekium.mx

For more information, go to: https://www.tekium.mx/
