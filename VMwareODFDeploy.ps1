Clear

# Configuration Parameters
$VMServer = ""
$OVFRoot = ""
$OVFTool = ""

# Check if initial setup has already taken place
IF (Get-Module -ListAvailable -Name VMware.PowerCLI){
    Write-Host "VMware OVF Deploy Tool"
    Write-Host "----------------------"
    Write-Host ""
    Write-Host "Enter your ESXi host credentials"
    $Creds = Get-Credential
    $Username = $Creds.GetNetworkCredential().Username
    $Password = $Creds.GetNetworkCredential().Password
}
ELSE { 
    Write-Host "Setting up for first run"
    Write-Host "------------------------"
    Write-Host ""  
    Find-Module -Name VMware.PowerCLI
    Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
    Set-ExecutionPolicy RemoteSigned 
    Clear
    Write-Host "VMware OVF Deploy Tool"
    Write-Host "----------------------"
    Write-Host ""
    Write-Host "Enter your ESXi host credentials"
    $Creds = Get-Credential
    $Username = $Creds.GetNetworkCredential().Username
    $Password = $Creds.GetNetworkCredential().Password
}

# Get list of available deployments
$Deployments = Get-ChildItem $OVFRoot | Select -ExpandProperty Name

# Create requried arrays
$DSArray = @()
$VPGArray = @()
$DPArray = @()
$vCPU = @(1..8)
$RAMArray = @(1024,2048,4096,8192,16384,32768,65536,131072)

Write-Host "Connecting to $VMServer"

Connect-VIServer -Server $VMServer -Protocol https -Credential $Creds

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""

# Get Datastores and Portgroups
$Datastores = Get-Datastore | Select -ExpandProperty Name
$VirtualPortGroups = Get-VirtualPortGroup | Select -ExpandProperty Name

# Add items to arrays
ForEach ($Datastore in $Datastores) {
    $DSArray += $Datastore
}

ForEach ($VirtualPortGroup in $VirtualPortGroups) {
    $VPGArray += $VirtualPortGroup
}

ForEach ($Deployment in $Deployments){
    $DPArray += $Deployment
}

Write-Host "Select an OVF to Deploy"
Write-Host ""

$DPCount = $DPArray.Count

$Count = 0

While ($Count -lt $DPCount){
    Write-Host $Count "-" $DPArray[$Count]
    $Count ++
}

Write-Host ""

$Deployment = Read-Host -Prompt "Enter deployment number"

$DP = $DPArray[$Deployment]

$DeploymentPath = "$OVFRoot\$DP"

$OVFName = Get-ChildItem $DeploymentPath -Filter "*.ovf" | Select -ExpandProperty Name

$OVF = "$OVFRoot\$DP\$OVFName"

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host ""
Write-Host ""
Write-Host "Select Number for vCPUs"
Write-Host ""

$vCPUCount = $vCPU.Count

$Count = 0

While ($Count -lt $vCPUCount){
    Write-Host $Count "-" $vCPU[$Count]
    $Count ++
}

Write-Host ""

$vCPUs = Read-Host -Prompt "Enter number of vCPUs"
$CPUs = $vCPU[$vCPUs]

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host ""
Write-Host ""
Write-Host "Select RAM Size"
Write-Host ""

$RAMCount = $RAMArray.Count

$Count = 0

While ($Count -lt $RAMCount){
    Write-Host $Count "-" ($RAMArray[$Count]/1024) "GB"
    $Count ++
}

Write-Host ""

$RAM = Read-Host -Prompt "Enter number for RAM"

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host "RAM:" ($RAMArray[$RAM]/1024) "GB"
Write-Host ""
Write-Host ""
Write-Host "Select Datastore"
Write-Host ""

$DSCount = $DSArray.Count

$Count = 0

While ($Count -lt $DSCount){
    Write-Host $Count "-" $DSArray[$Count]
    $Count ++
}

Write-Host ""

$Datastore = Read-Host -Prompt "Enter number of the Datastore"
$DS = $DSArray[$Datastore]

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host "RAM:" ($RAMArray[$RAM]/1024) "GB"
Write-Host "Datastore: $DS"
Write-Host ""
Write-Host ""
Write-Host "Select VM Network"
Write-Host ""

$VPGCount = $VPGArray.Count

$Count = 0

While ($Count -lt $VPGCount){
    Write-Host $Count "-" $VPGArray[$Count]
    $Count ++
}

Write-Host ""

$VirtualPortGroup = Read-Host -Prompt "Enter number of the VM Network"
$NW = $VPGArray[$VirtualPortGroup]

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host "RAM:" ($RAMArray[$RAM]/1024) "GB"
Write-Host "Datastore: $DS"
Write-Host "Network: $NW"
Write-Host ""
Write-Host ""
Write-Host "Specify Count of VMs to be created"
Write-Host ""
$VMCount = Read-Host -Prompt "Enter number of VMs to Create"

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host "RAM:" ($RAMArray[$RAM]/1024) "GB"
Write-Host "Datastore: $DS"
Write-Host "Network: $NW"
Write-Host "Number of VMs: $VMCount"
Write-Host ""
Write-Host ""
Write-Host "Specify VM Name - Auto Incrementing numbers will be appended"
Write-Host ""
$VMName = Read-Host -Prompt "Enter VM Name"

Clear

Write-Host "VMware OVF Deploy Tool"
Write-Host "----------------------"
Write-Host ""
Write-Host "Review Configuration Options"
Write-Host ""
Write-Host "Image: $DP"
Write-Host "vCPUs: $CPUs"
Write-Host "RAM:" ($RAMArray[$RAM]/1024) "GB"
Write-Host "Datastore: $DS"
Write-Host "Network: $NW"
Write-Host "Number of VMs: $VMCount"
Write-Host "VM Name: $VMName"
Write-Host ""
Write-Host ""

$DeployConf = Read-Host -Prompt "Do these options look correct? (Y/N)"

if ($DeployConf -eq "Y"){
    [xml]$OVFXML = Get-Content $OVF

    # Set Network
    $OVFXML.Envelope.NetworkSection.Network.name = "$NW"
    $OVFXML.Envelope.VirtualSystem.VirtualHardwareSection.Item[11].Connection = "$NW"

    # Set vCPUs
    $OVFXML.Envelope.VirtualSystem.VirtualHardwareSection.Item[0].VirtualQuantity = "$CPUs"

    # Set RAM
    $Memory = $RAMArray[$RAM]
    $OVFXML.Envelope.VirtualSystem.VirtualHardwareSection.Item[1].VirtualQuantity = "$Memory"

    # Save OVF Deployment Template
    $OVFXML.Save($OVF)

    

    # Start Deployment Process
    $DeployCount = @(1..$VMCount)

    ForEach ($Deploy in $DeployCount) {
        Start-Process $OVFTool -ArgumentList "--skipManifestCheck -ds=`"$DS`" -n=`"$VMName$Deploy`" `"$OVF`" vi://$Username`:$Password@$VMServer"
    }
}