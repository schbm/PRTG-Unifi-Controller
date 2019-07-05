# RUN THE FOLLOWING COMMAND WITH CMD TO ENABLE SCRIPT EXECUTION WITH 32BIT PS
#%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe "Set-ExecutionPolicy RemoteSigned"

param(
    [string] $serverName = 'server01',
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

        $ErrorActionPreference = "Stop"; #Needed for the try & catch

        try {
            Get-VMReplication | where {$_.Mode -EQ 'Replica'}; 
        } catch {
            return 'error'
        }
    }

    # Disconnect Session
    $disc = Disconnect-PSSession $session

    # Check if the invokation has thrown errors
    if ($result -eq 'error') {
        $out = "<prtg>"
	    $out += "<error>1</error>"
	    $out += "<text>Error getting Hyper-V data</text>"
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

$out = "<prtg>"

ForEach($replica in $result) {
    $working = 0
    if ($replica.Health -eq 'Warning') {
        $working = 1
    } elseIf ($replica.Health -ne 'Normal') {
        $working = 2
    }

    $out += ("<result>
                    <channel>"+$replica.Name+"</channel>
                    <unit>SingleInt</unit>
                    <value>"+$working+"</value>
                    <LimitMaxError>1.5</LimitMaxError>
                    <LimitMaxWarning>0.5</LimitMaxWarning>
                    <LimitWarningMsg>Attention! replication warning</LimitWarningMsg>
                    <LimitErrorMsg>Attention! replication error!</LimitErrorMsg>
                    <LimitMode>1</LimitMode>
                </result>")
}

$out += "</prtg>"

$out = $out -replace '&','und'

format-xml -xml $out


