# ============================================================
# M365 Tenant Health Monitor
# Author: Joseph Sanwo | github.com/jsanwo85
# Description: Monitors Microsoft 365 service health via
#              Graph API and sends email alert on degradation
# Date: June 2026
# ============================================================

# ---- CONFIGURATION ----
$TenantId     = "e12a7116-54fc-471b-8119-62640cf660be"
$ClientId     = "6541e1c7-ebe7-4aa5-8114-712656234764"
$ClientSecret = "YOUR-CLIENT-SECRET-HERE"
$AlertFrom    = "JosephSanwo@JSanwoLab.onmicrosoft.com"
$AlertTo      = "sanwo.joseph07@gmail.com"
# ------------------------

# Convert secret to secure credential
$SecureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
$Credential   = New-Object System.Management.Automation.PSCredential($ClientId, $SecureSecret)

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $Credential -NoWelcome

# Get service health
Write-Host "Fetching M365 service health..." -ForegroundColor Cyan
$HealthOverview = Get-MgServiceAnnouncementHealthOverview

# Define healthy status
$HealthyStatus = "serviceoperation"

# Filter degraded services
$Issues = $HealthOverview | Where-Object { $_.Status -ne $HealthyStatus }

# Timestamp
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

if ($Issues.Count -eq 0) {
    Write-Host "[$Timestamp] All M365 services healthy. No action needed." -ForegroundColor Green
} else {
    Write-Host "[$Timestamp] ALERT: $($Issues.Count) service(s) degraded:" -ForegroundColor Red
    $Issues | ForEach-Object {
        Write-Host "  - $($_.Service): $($_.Status)" -ForegroundColor Yellow
    }

    # Save alert to log file
    $AlertLog = "$PSScriptRoot\alert-log.txt"
    $AlertEntry = "[$Timestamp] ALERT: $($Issues.Count) degraded - $($Issues.Service -join ', ')"
    Add-Content -Path $AlertLog -Value $AlertEntry
    Write-Host "Alert saved to: $AlertLog" -ForegroundColor Yellow

    # Try sending email
    $EmailBody = "<h2>M365 Alert</h2><p>$AlertEntry</p>"
    $Message = @{
        message = @{
            subject = "[$Timestamp] ALERT: M365 Service Degradation"
            body = @{
                contentType = "HTML"
                content = $EmailBody
            }
            toRecipients = @(
                @{ emailAddress = @{ address = $AlertTo } }
            )
        }
        saveToSentItems = $false
    }

    try {
        Send-MgUserMail -UserId $AlertFrom -BodyParameter $Message
        Write-Host "Alert email sent to $AlertTo" -ForegroundColor Green
    } catch {
        Write-Host "Email not sent - alert logged to file instead." -ForegroundColor Yellow
    }
}

# Log to CSV
$LogPath = "$PSScriptRoot\health-log.csv"
$HealthOverview | Select-Object Service, Status,
    @{N="Timestamp";E={$Timestamp}} |
    Export-Csv -Path $LogPath -Append -NoTypeInformation

Write-Host "Log updated: $LogPath" -ForegroundColor Cyan

# Disconnect
Disconnect-MgGraph
Write-Host "Done." -ForegroundColor Cyan