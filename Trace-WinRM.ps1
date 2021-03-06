function Write-Log {
    param (
        [string]$Message,
        [string]$Type,
        [string]$Path
    )
    $msg = ("[" + $Type + "] " + $Message)
    Write-Host $msg 
    Out-File -InputObject $msg -PSPath ($Path + '\' + $env:COMPUTERNAME + '-WinRM-Trace-Log.log') -Append

}

function Get-CurrentTime {
    return (Get-Date -Format "yyyy/MM/dd-hh:mm:ss.fffffff")
}

function Trace-WinRM {
    $IsSender = $false
    $Node = ""
    $Path = ""

    $Path = Read-Host "Please enter the full path for the files to be generated in"
    if($Path[-1] -eq "\") {$Path = $Path.Substring(0,$Path.Length - 1)}

    if((Read-Host "Is this computer the sender? (Y/N)").ToLower() -eq "y") {
        $IsSender = $true
        Write-Log -Message ("Setup " + $env:COMPUTERNAME + " as the WinRM Sender") -Type "INFO" -Path $Path
    }

    if($IsSender -eq $true) {
        $Node = Read-Host "Please enter the hostname / ip of the node that will run in receiver mode"
    }

    Write-Log -Message "Grabbing WinRM Config" -Type "INFO" -Path $Path
    winrm get winrm/config | Out-File -PSPath ($Path + '\' + $env:COMPUTERNAME + '-WinRM-Config-Dump.txt')

    Write-Log -Message "Starting Logman" -Type "INFO" -Path $Path
    logman create trace "WinRM-Trace" -ow -o ($Path + '\' + $env:COMPUTERNAME + '-WinRM-Logman-trace.etl') -p "Microsoft-Windows-WinRM" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 2048 -ets

    Write-Log -Message "Starting NetSh" -Type "INFO" -Path $Path
    netsh trace start maxSize=1024MB capture=yes tracefile= ($Path + '\' + $env:COMPUTERNAME + '-WinRM-Network-trace.etl')

    Write-Log -Message "Stopping WinRM" -Type "INFO" -Path $Path
    Stop-Service -Name "WinRM" -Force

    Write-Log -Message "Starting WinRM" -Type "INFO" -Path $Path
    Start-Service -Name "WinRM"

    if($IsSender -eq $true) {
        Write-Log -Message (Get-CurrentTime + " Starting Test-WSMan") -Type "INFO" -Path $Path
        Test-WSMan -ComputerName $Node -ErrorAction SilentlyContinue
        Write-Log -Message (Get-CurrentTime + " Finished Test-WSMan") -Type "INFO" -Path $Path
    } else {
        Read-Host -Prompt "Please press any key once the sender is showing 'Finished Test-WSMan' " | Out-Null
    }


    Write-Log -Message "Stopping WinRM" -Type "INFO" -Path $Path
    Stop-Service -Name "WinRM" -Force

    Write-Log -Message "Stopping Logman" -Type "INFO" -Path $Path
    logman stop "WinRM-Trace" -ets
    
    Write-Log -Message "Starting WinRM" -Type "INFO" -Path $Path
    Start-Service -Name "WinRM"

    Write-Log -Message "Stopping NetSh" -Type "INFO" -Path $Path
    netsh trace stop
}

Trace-WinRM