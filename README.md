# M365 Health Monitor 

Automated Microsoft 365 service health monitoring using PowerShell and Microsoft Graph API.

## Project Overview
This project monitors the health of Microsoft 365 services in real time using the Microsoft Graph API. It runs automatically every 30 minutes via Windows Task Scheduler and logs all service statuses to a CSV file. If any service degrades, an alert is triggered.

## Architecture

PowerShell Script
      ↓
Microsoft Graph API (ServiceHealth.Read.All)
      ↓
M365 Tenant Health Data
      ↓
├── health-log.csv (continuous logging)
└── Email Alert (on degradation)

## Technologies Used
- PowerShell 5.1
- Microsoft Graph API
- Microsoft Graph PowerShell SDK (v2.37.0)
- Azure App Registration (Entra ID)
- Windows Task Scheduler
- Microsoft 365 Business Tenant

## Setup Requirements
- Microsoft 365 tenant (admin access)
- Azure App Registration with these permissions:
  - `ServiceHealth.Read.All` (Application)
  - `Mail.Send` (Application)
- Microsoft Graph PowerShell SDK installed
- PowerShell execution policy set to RemoteSigned

##  How to Run

### 1. Install Microsoft Graph SDK
powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```

### 2. Configure credentials in script
powershell
$TenantId     = "YOUR-TENANT-ID"
$ClientId     = "YOUR-CLIENT-ID"
$ClientSecret = "YOUR-CLIENT-SECRET"
$AlertFrom    = "admin@yourtenant.onmicrosoft.com"
$AlertTo      = "your-email@gmail.com"
```

### 3. Run the script
powershell
.\M365-HealthMonitor.ps1


### 4. Schedule it (optional)
powershell
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"C:\Projects\M365-HealthMonitor\M365-HealthMonitor.ps1`""
$Trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 30) -Once -At (Get-Date)
Register-ScheduledTask -TaskName "M365-HealthMonitor" -Action $Action -Trigger $Trigger -RunLevel Highest -Force
```

## Sample Output

Connecting to Microsoft Graph...
Fetching M365 service health...
[2026-06-06 15:45] All M365 services healthy. No action needed.
Log updated: C:\Projects\M365-HealthMonitor\health-log.csv
Done.
```

## Screenshots
See `/screenshots` folder for full implementation walkthrough.

## Author
**Joseph Sanwo** | [github.com/jsanwo85](https://github.com/jsanwo85)  
MSc Applied Cyber Security | Microsoft Certified: Azure Solutions Architect Expert
