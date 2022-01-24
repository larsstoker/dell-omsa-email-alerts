# Dell OMSA Email Alerts
This PowerShell script will configure OMSA to send out emails when an alert is generated.

It will include the following:
- System information from `omreport chassis info`
- Storage information from `omreport storage vdisk`
- Attach the system alert log from `omreport system alertlog`

This script is based on [this script](https://www.tachytelic.net/2011/09/dell-poweredge-email-alerts/) by Paul Murana.

# How to use
- Place the `OMAlert.ps1` in a folder on your system, mine is under `C:\Scripts\`. 
- Edit the variables under `$mailArgs` to match your settings:
  > :warning: It's best to use an encrypted file instead of a plaintext password in a script, the below is just a simple example.
  ```PowerShell
  # Default mail arguments
  $mailArgs = @{
  To = "example@example.com"
  From = "example@example.com"
  Credential = New-Object System.Management.Automation.PSCredential ("example@example.com", ("password" | ConvertTo-SecureString -AsPlainText -Force ))
  SmtpServer = "smtp.example.com"
  Port = "587"
  UseSsl = $true
  }
  ```

## Send a test email
- Execute the script with the param `testemail`.
  ```PowerShell
  PS C:\Scripts> .\OMAlert.ps1 testemail
  ```
  ![](https://raw.githubusercontent.com/larsstoker/dell-omsa-email-alerts/master/images/omsaTestEmail.jpg)

## Configure OMSA
- Execute the script with the param `configure`, this will both     configure OMSA and create a bunch of .bat scripts in the same directory.

  These scripts are called by OMSA once an alert is generated.

  ```PowerShell
  PS C:\Scripts> .\OMAlert.ps1 configure
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  Alert action(s) configured successfully.
  PS C:\Scripts>
  ```

## Test functionality
You can test if the script did it's job by temporarily lowering the `Temperature Threshold` settings.
![](https://raw.githubusercontent.com/larsstoker/dell-omsa-email-alerts/master/images/omsaTempThreshold.jpg)

This should generate an alert and send out an email.

## Clear configuration
To clear all alert configurations, execute the script with the param `clearall`.
