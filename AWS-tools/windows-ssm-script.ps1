<powershell>​
$dir = $env:TEMP + "\ssm"  
New-Item -ItemType directory -Path $dir -Force  
cd $dir  
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")  
Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait  
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
</powershell>​
