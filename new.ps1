Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,
    
    [string]
    $DeploymentID,

    [string]
    $azuserobjectid,

    [string]
    $adminUsername,

    [string]
    $adminPassword

    
)
Start-Transcript -Path C:\Logs\logontasklogs1.txt -Append

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"



#InstallAzPowerShellModule
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/Azure/azure-powershell/releases/download/v5.0.0-October2020/Az-Cmdlets-5.0.0.33612-x64.msi","C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi")
sleep 5
Start-Process msiexec.exe -Wait '/I C:\Packages\Az-Cmdlets-5.0.0.33612-x64.msi /qn' -Verbose


$userName = $AzureUserName
$password = $AzurePassword


$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

Connect-AzAccount -Credential $cred | Out-Null

$resourceGroupName = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "*modern-$deploymentId*" }).ResourceGroupName
$deploymentId =  (Get-AzResourceGroup -Name $resourceGroupName).Tags["DeploymentId"]

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri "https://onbb.blob.core.windows.net/onbbb/synapse.json" -TemplateParameterUri "https://onbb.blob.core.windows.net/onbbb/vm.json"


#install power bi
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.microsoft.com/download/3/C/0/3C0A5D40-85C6-4959-BB51-3A2087B18BCA/PBIDesktopRS_x64.msi","C:\Packages\PBIDesktop_x64.msi")
Start-Process msiexec.exe -Wait '/I C:\Packages\PBIDesktop_x64.msi /qr ACCEPT_EULA=1'

#install .net
$scriptPath = Join-Path $env:TEMP "dotnet-sdk-3.1.426-win-x64.exe"
Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/b70ad520-0e60-43f5-aee2-d3965094a40d/667c122b3736dcbfa1beff08092dbfc3/dotnet-sdk-3.1.426-win-x64.exe' -OutFile $scriptPath
Start-Process -FilePath $scriptpath -ArgumentList '/S' -Wait


Stop-Transcript