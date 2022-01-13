# This script will configure Dell OMSA to send emails based on alerts
# Based on https://www.tachytelic.net/2011/09/dell-poweredge-email-alerts/

#
# Params
#
Param(
  [string]$action,
  [string]$alertId
)
#!endRegion

#
# Variables
#
$alertDefinitions = "powersupply|Power supply failure", "powersupplywarn|Power supply warning", "tempwarn|Temperature warning", "tempfail|Temperature failure", "fanwarn|Fan speed warning", "fanfail|Fan speed failure", "voltwarn|Voltage warning", "voltfail|Voltage failure", "intrusion|Chassis intrusion", "redundegrad|Redundancy degraded", "redunlost|Redundancy lost", "memprefail|Memory pre-failure", "memfail|Memory failure", "hardwarelogwarn|Hardware log warning", "hardwarelogfull|Hardware log full", "processorwarn|Processor warning", "processorfail|Processor failure", "watchdogasr|Watchdog asr", "batterywarn|Battery warning", "batteryfail|Battery failure", "systempowerwarn|Power warning", "systempowerfail|Power failure", "systempeakpower|Peak power", "removableflashmediapresent|Removable flash media present", "removableflashmediaremoved|Removable flash media removed", "removableflashmediafail|Removable flash media failure", "storagesyswarn|Storage System warning", "storagesysfail|Storage System failure", "storagectrlwarn|Storage Controller warning", "storagectrlfail|Storage Controller failure", "pdiskwarn|Physical Disk warning", "pdiskfail|Physical Disk failure", "vdiskwarn|Virtual Disk warning", "vdiskfail|Virtual Disk failure", "enclosurewarn|Enclosure warning", "enclosurefail|Enclosure failure", "storagectrlbatterywarn|Storage Controller Battery warning", "storagectrlbatteryfail|Storage Controller Battery failure"
# OmReport info for the email body
$chassisInfo = Invoke-Expression "omreport chassis info" | Out-String
$storageInfo = Invoke-Expression "omreport storage vdisk" | Out-String
# Default mail arguments
$mailArgs = @{
  To = "example@example.com"
  From = "example@example.com"
  Credential = New-Object System.Management.Automation.PSCredential ("example@example.com", ("password" | ConvertTo-SecureString -AsPlainText -Force ))
  SmtpServer = "smtp.example.com"
  Port = "587"
  UseSsl = $true
}
#!endRegion

#
# Actions
#
# Configure OMA to execute script on alert
if ($action -eq "configure") {
  for ($i = 0; $i -lt $alertDefinitions.count; $i++) {
    # Split $alertDefinitions at the "|" to get the command and description.
    # 0 being the command used for the actual OMA command line config.
    $alertCommand = $alertDefinitions[$i].split("|")[0]

    # Create .bat file for each action, for some reason it's not possible to passthrough powershell.exe with params through omconfig.
    # It does work if it's manually specified in the Webui but that won't do for this script.
    $batCommand = "$PSHOME\powershell.exe $PSScriptRoot\OMAlert.ps1 email $i"
    $batCommand | Out-File -FilePath "$PSScriptRoot\$alertCommand.bat" -Encoding ascii -Force

    # Configure oma to execute the .bat files
    $configureOma = "omconfig system alertaction event=$alertCommand execappath=$PSScriptRoot\$alertCommand.bat"
    Invoke-Expression $configureOma
  }
}
# Send an email
elseif ($action -eq "email") {
  # Split $alertDefinitions at the "|" to get the command and description.
  # 1 being the alert description used in the email.
  $alertSubject = $alertDefinitions[$alertId].split("|")[1]
  $emailSubject = "Dell OMSA Alert on $ENV:COMPUTERNAME - $alertSubject"
  $htmlBody = "
            <pre>$chassisInfo</pre>
            <br>
            <br>
            <pre>$storageInfo</pre>
            "
  # Generate alert logfile
  Invoke-Expression "omreport system alertlog -outc $PSScriptRoot\alertLog.txt"
  
  # Send the email
  Send-MailMessage @mailArgs -Subject $emailSubject -BodyAsHtml $htmlBody -Attachments "$PSScriptRoot\alertLog.txt"
}
# Send a test email
elseif ($action -eq "testemail") {
  $emailSubject = "Dell OMSA Test Email"
  $htmlBody = "
            <pre>$chassisInfo</pre>
            <br>
            <br>
            <pre>$storageInfo</pre>
            "
  
  Send-MailMessage @mailArgs -Subject $emailSubject -BodyAsHtml $htmlBody
}
# Clear alert configuration
elseif ($action -eq "clearall") {
  for ($i = 0; $i -lt $alertDefinitions.count; $i++) {
    $alertCommand = $alertDefinitions[$i].split("|")[0]
  
    $configureOma = "omconfig system alertaction event=$alertCommand clearall=true"
    Invoke-Expression $configureOma
  }
}
# If no arguments were used
elseif (!($action)) {
  Write-Host "No agruments used, exiting script..."
}
#!endRegion