# PRTG-Unifi-Controller

Current functionality:
- Show all Devices
- Show Upgradable devices
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