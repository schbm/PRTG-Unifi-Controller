#%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe "Set-ExecutionPolicy RemoteSigned"

param(
	[string]$server = '127.0.0.1',
	[string]$port = '8443',
	[string]$site = 'default',
	[string]$username = 'admin',
	[string]$password = '1234',
	[switch]$debug = $false
)

#Ignore SSL Errors
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}  

#Define supported Protocols
[System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")


# Confirm Powershell Version.
if ($PSVersionTable.PSVersion.Major -lt 3) {
	Write-Output "<prtg>"
	Write-Output "<error>1</error>"
	Write-Output "<text>Powershell Version is $($PSVersionTable.PSVersion.Major) Requires at least 3. </text>"
	Write-Output "</prtg>"
	Exit
}

[string]$controller = "https://$($server):$($port)"
[string]$credential = "`{`"username`":`"$username`",`"password`":`"$password`"`}"

# Start debug timer
$queryMeasurement = [System.Diagnostics.Stopwatch]::StartNew()


try {
$null = Invoke-Restmethod -Uri "$controller/api/login" -method post -body $credential -ContentType "application/json; charset=utf-8"  -SessionVariable myWebSession
}catch{
	Write-Output "<prtg>"
	Write-Output "<error>1</error>"
	Write-Output "<text>Authentication Failed: $($_.Exception.Message)</text>"
	Write-Output "</prtg>"
	Exit
}

try {
$jsonresultat = Invoke-Restmethod -Uri "$controller/api/s/$site/stat/device/" -WebSession $myWebSession

}catch{
	Write-Output "<prtg>"
	Write-Output "<error>1</error>"
	Write-Output "<text>API Query Failed: $($_.Exception.Message)</text>"
	Write-Output "</prtg>"
	Exit
}

$deviceArr = @()
$deviceOn  = 0
$deviceOff = 0
$upgradableDevices = 0

Foreach ($entry in ($jsonresultat.data)){
	$device = New-Object System.Object
    $device | Add-Member -MemberType NoteProperty -Name name -Value $entry.name
    $device | Add-Member -MemberType NoteProperty -Name ip -Value $entry.ip
    $device | Add-Member -MemberType NoteProperty -Name status -Value $entry.state

    if($entry.state -eq 1) {
        $deviceOn +=1
    }
    else {
        $deviceOff +=1
    }

    if($entry.upgradable -eq "true"){
        $upgradableDevices += 1
    }

    $deviceArr += $device
}

write-host "<prtg>"

Foreach ($deviceEntry in $deviceArr){
    Write-Host "<result>"
    Write-Host "<channel>$($deviceEntry.name) ($($deviceEntry.ip))</channel>"
    Write-Host "<value>$($deviceEntry.status)</value>"
    Write-Host "</result>"
}

    Write-Host "<result>"
    Write-Host "<channel>Total Up</channel>"
    Write-Host "<value>$($deviceOn)</value>"
    Write-Host "</result>"

    Write-Host "<result>"
    Write-Host "<channel>Total Down</channel>"
    Write-Host "<value>$($deviceOff)</value>"
    Write-Host "</result>"

    Write-Host "<result>"
    Write-Host "<channel>Upgradable Devices</channel>"
    Write-Host "<value>$($upgradableDevices)</value>"
    Write-Host "</result>"

write-host "</prtg>"
