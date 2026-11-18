<powershell>
#awscli
irm 'https://awscli.amazonaws.com/v2/install.ps1' -OutFile install.ps1; try { .\install.ps1 -System } finally { Remove-Item install.ps1 }
#ssm​
$dir = $env:TEMP + "\ssm"  
New-Item -ItemType directory -Path $dir -Force  
cd $dir  
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")  
Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait  
#ssh
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#rdp
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
#icmp
netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=yes
#Falcon/Crowdstrike
cd C:\Windows\Temp
Read-S3Object -BucketName cso-edr-agent-installers -Key Windows/FalconSensor_Windows.exe -File "crowdstrike_installer.exe" -Region us-east-1
$install_token_secret = Get-SECSecretValue -SecretId "arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/install_token-61v6Nq" -Region us-east-1
$install_token_json = $install_token_secret.SecretString | ConvertFrom-Json
$install_token = $install_token_json.CrowdStrike_Install_Token
$cid_secret = Get-SECSecretValue -SecretId "arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/cid-iAuBMG" -Region us-east-1
$cid_json = $cid_secret.SecretString | ConvertFrom-Json
$cid = $cid_json.CrowdStrike_CID
.\crowdstrike_installer.exe /install /quiet /log C:\Windows\Temp\cs_install_log.txt /norestart ProvNoWait=1 CID=$cid ProvToken=$install_token PACURL=http://proxyconf-aae-vn.siemens.net:81/proxyvn.pac
Start-Sleep -Seconds 120
$AGENT_ID = reg query HKLM\System\CurrentControlSet\services\CSAgent\Sim\ /f AG
"$AGENT_ID" | out-file -filepath C:\Users\Administrator\Desktop\AGENT_ID.txt -append -width 200
</powershell>​
