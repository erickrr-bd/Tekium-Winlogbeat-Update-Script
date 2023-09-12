# Tekium-Winlogbeat-Update-Script v1.3

It's a tool that updates the version of the Winlogbeat agent (Elastic) on Windows systems through the domain controller.

Born from the need to have a tool that is easy to run and use. Ideal if the automated and massive update of Winlogbeat is required in your organization.

# Characteristics
- It's only necessary to run the tool in the domain controller

# Requirements
- Access to the domain controller.
- PowerShell (A recent version is recommended)
- PowerShell Console (Executed with administrator permissions)
- Script execution enabled (Otherwise, run `Set-ExecutionPolicy Unrestricted`)
- WinRM
- Communication through port 5985

# Running

By default, the script looks in C:\ and files with the extension txt, csv, and log. 

This can be changed using the parameters: "path_search", where the path where the search will be performed (recursively) is indicated. The other is "filters" where the file types where the PANs will be searched are indicated, these must be specified as follows: '*.txt', '*.docx', '*.xlsx' (separated by commas).

For example:

`.\Tekium_PAN_Hunter_Script.ps1 -path_search “C:\Users” -filters ‘*.log’, ‘*.txt’, ‘*.csv’, ‘*.docx’, ‘*.xlsx’, ‘*.xls’, ‘*.doc’`

# Example output

```
-------------------------------------------------------------------------------------
Copyright©Tekium 2023. All rights reserved.
Author: Erick Roberto Rodriguez Rodriguez
Email: erodriguez@tekium.mx, erickrr.tbd93@gmail.com
GitHub: https://github.com/erickrr-bd/Tekium-PAN-Hunter-Script
Tekium PAN Hunter Script v1.1.2 for Windows - June 2023
-------------------------------------------------------------------------------------
Hostname: LAPTOP-NUDA94QT
Path: C:\Users\reric\Downloads
Filters: *.log *.txt *.csv *.docx *.xlsx *.xls *.doc

 XXXXXXXXXXXX0004  MASTER CARD
 XXXXXXXXXXXX0055  MASTER CARD
 XXXXXXXXXXXX0006  MASTER CARD
 XXXXXXXXXXXX0009  VISA
 XXXXXXXXXXXX0004  VISA

Possible PAN's found in: C:\Users\reric\Downloads\Nuevo Documento de texto.txt.FullName
```

# Commercial Support
![Tekium](https://github.com/unmanarc/uAuditAnalyzer2/blob/master/art/tekium_slogo.jpeg)

Tekium is a cybersecurity company specialized in red team and blue team activities based in Mexico, it has clients in the financial, telecom and retail sectors.

Tekium is an active sponsor of the project, and provides commercial support in the case you need it.

For integration with other platforms such as the Elastic stack, SIEMs, managed security providers in-house solutions, or for any other requests for extending current functionality that you wish to see included in future versions, please contact us: info at tekium.mx

For more information, go to: https://www.tekium.mx/
