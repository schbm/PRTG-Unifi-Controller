# PRTG-Unifi-Controller

Ver 0.1

Current functionality:
- Show all Devices
- Show Upgradable devices
- Total Up & Down

Parameter:
-[string]$server    *
-[string]$port
-[string]$site      *
-[string]$username  *
-[string]$password  *
-[switch]$debug
* Possibly required


In PRTG create new EXE/XML Sensor an pass parameters like this:
```
-server 'test.test.test' -password 'test' -site 'XGAHSDG'
```