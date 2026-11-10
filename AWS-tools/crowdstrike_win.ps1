#crowdstrike windows install script
#check for admin
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Write-Host 'Not running as admin' } Else { Write-Host 'Running as admin' }

#uninstall Sentinel One
try {
$s1_version = (Get-Item "C:\Program Files\SentinelOne\Sentinel Agent *\SentinelAgent.exe").VersionInfo.ProductVersion
cd "C:\Program Files\SentinelOne\Sentinel Agent $s1_version\"
.\uninstall.exe /uninstall /norestart /q 
Start-Sleep -Seconds 2
} catch {
  "An error occurred while attempting to uninstall Sentinel One, perhaps it was never installed"
  }

try {
cd C:\Windows\Temp
Read-S3Object -BucketName cso-edr-agent-installers -Key Windows/FalconSensor_Windows.exe -File "crowdstrike_installer.exe" -Region us-east-1
$install_token_secret = Get-SECSecretValue -SecretId "arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/install_token-61v6Nq" -Region us-east-1
$install_token_json = $install_token_secret.SecretString | ConvertFrom-Json
$install_token = $install_token_json.CrowdStrike_Install_Token
$cid_secret = Get-SECSecretValue -SecretId "arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/cid-iAuBMG" -Region us-east-1
$cid_json = $cid_secret.SecretString | ConvertFrom-Json
$cid = $cid_json.CrowdStrike_CID
Start-Sleep -Seconds 2
} catch {
  "Failure pulling secrets from AWS"
  }

#run the installer
try {
.\crowdstrike_installer.exe /install /quiet /log C:\Windows\Temp\cs_install_log.txt /norestart ProvNoWait=1 CID=$cid ProvToken=$install_token PACURL=http://proxyconf-aae-vn.siemens.net:81/proxyvn.pac
Start-Sleep -Seconds 2
} catch {
 "Failure running the installer"
 }

#start the service
try {
Start-Service -Name "CSFalconService"
Write-Host "Started the CSFalconService"
Write-Host "Please be patient while Falcon receives its agent ID"
Start-Sleep -Seconds 100
Write-Host 'CS Falcon installed'
Write-Host 'Agent ID:'
reg query HKLM\System\CurrentControlSet\services\CSAgent\Sim\ /f AG
} catch {
  "Failure starting the service and/or getting the Agent ID"
  }
  

Exit
