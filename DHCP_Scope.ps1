# RUN THE FOLLOWING COMMAND WITH CMD TO ENABLE SCRIPT EXECUTION WITH 32BIT PS
#%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe "Set-ExecutionPolicy RemoteSigned"
##
## CURRENTLY NEEDS DOMAIN JOINED REMOTE-PROBE
##
param(
    [string] $serverName = 'server01',
    [string] $scopeName = '192.168.40.0',
    [string] $userName = "admin",
    [string] $passWord = "1234"
)

# Helper function
function Format-XML ([xml]$xml, $indent=2)
{
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = “indented”
    $xmlWriter.Indentation = $Indent
    $xml.WriteContentTo($XmlWriter)
    $XmlWriter.Flush()
    $StringWriter.Flush()
    Write-Output $StringWriter.ToString()
}

# Convert the password to use it in a credential object
$secPass = ConvertTo-SecureString -AsPlainText $Password -Force
# Create new credential object
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $userName,$secPass

$ErrorActionPreference = "Stop"; #Needed for the try & catch

try {
    
    # Connect to remote machine
    $session = New-PSSession -ComputerName $serverName -Credential $cred

    # Get scope statistics
    $result = Invoke-Command -Session $session {
    
        param($scopeName) 

        $ErrorActionPreference = "Stop"; #Needed for the try & catch

        try {
            Get-DhcpServerv4ScopeStatistics -ScopeId $scopeName -ErrorVariable $err| Select ScopeID,AddressesFree,AddressesInUse,PercentageInUse,ReservedAddress 
        } catch {
            return 'error'
        }
    } -Args $scopeName

    # Disconnect Session
    $disc = Disconnect-PSSession $session

    # Check if the invokation has thrown errors
    if ($result -eq 'error') {
        $out = "<prtg>"
	    $out += "<error>1</error>"
	    $out += "<text>Error getting DHCP scope data</text>"
	    $out += "</prtg>"
        Format-XML -xml $out
	    Exit
    }

# Catch connection errors
} catch { 
    $out = "<prtg>"
	$out += "<error>1</error>"
	$out += "<text>Error invoking command to remote server</text>"
	$out += "</prtg>"
    Format-XML -xml $out
	Exit
}


$out = '<prtg>'

$out += ("<result><channel>PercentageInUse</channel><unit>Percent</unit><mode>Absolute</mode><showChart>1</showChart><showTable>1</showTable><warning>0</warning><float>1</float><value>"+$result.PercentageInUse+"</value><LimitMaxError>90</LimitMaxError><LimitMaxWarning>75</LimitMaxWarning><LimitWarningMsg>Attention 75% des adresse IP affectes !</LimitWarningMsg><LimitErrorMsg>Attention 90% des adresse IP affectes !</LimitErrorMsg><LimitMode>1</LimitMode></result>")
$out += ("<result><channel>AddressesInUse</channel><unit>Custom</unit><customUnit>IP</customUnit><mode>Absolute</mode><showChart>1</showChart><showTable>1</showTable><float>0</float><value>"+$result.AddressesInUse+"</value></result>")
$out += ("<result><channel>AddressesFree</channel><unit>Custom</unit><customUnit>IP</customUnit><mode>Absolute</mode><showChart>1</showChart><showTable>1</showTable><float>0</float><value>"+$result.AddressesFree+"</value></result>")
$out += ("<result><channel>ReservedAddress</channel><unit>Custom</unit><customUnit>IP</customUnit><mode>Absolute</mode><showChart>1</showChart><showTable>1</showTable><float>0</float><value>"+$result.ReservedAddress+"</value></result>")

$out += "</prtg>"

Format-XML -xml $out


