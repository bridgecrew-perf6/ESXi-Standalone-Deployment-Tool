# Introduction 
This tool allows for the deployment of VM templates to standalone ESXi servers

# Dependencies
- Windows
- PowerShell
- OVF Tool 4.4
- VMware PowerCLI

# Configuration
The following configuration paramaters must be set
```
# Configuration Parameters
$VMServer = ""
$OVFRoot = ""
$OVFTool = ""
```

$VMServer is the IP or Hostname of the ESXi host
$OVFRoot is the path to where all OVFs are stored
$OVFTool is the installation path of the OVFTool