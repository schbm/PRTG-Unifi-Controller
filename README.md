﻿# Powershell Repository

## Unifi-Devices.ps1

Editet version of a powershell script interacting with the Unifi-Controller API.

Currently the script fetches following information:
- All Devices
- Upgradable devices
- Total Up & Down

Parameter:
- [string]$server    *
- [string]$port
- [string]$site      *
- [string]$username  *
- [string]$password  *
- [switch]$debug

\* Possibly required

In PRTG create new **_EXE/XML_** Sensor an pass parameters like this:
```
-server 'test.test.test' -password 'test' -site 'XGAHSDG'
```

Sources:
- [Unifi Controller API](https://ubntwiki.com/products/software/unifi-controller/api)
- [PRTG Unifi \(GER\)](https://www.msxfaq.de/tools/prtg/prtg_mit_ubiquiti.htm)
