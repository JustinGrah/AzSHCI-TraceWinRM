function Write-Log {
    param (
        [string]$Message,
        [string]$Type
    )
    $msg = ("[" + $Type + "] " + $Message)
    Write-Host $msg 
    Out-File -InputObject $msg -PSPath ('C:\temp\Trace-' + $env:COMPUTERNAME + 'WinRM.log') -Append

}

function Get-CurrentTime {
    return (Get-Date -Format "yyyy/MM/dd-hh:mm:ss.fffffff")
}

function Trace-WinRM {
    param([bool]$IsSender)
    If((Test-Path -Path "C:\temp") -eq $false) {
        New-Item -Path "C:\" -ItemType Directory -Name "temp"
    }

    Write-Log -Message "Grabbing WinRM Config" -Type "INFO"
    winrm get winrm/config | Out-File -PSPath ('C:\temp\WinRM-Config-' + $env:COMPUTERNAME + '.txt')

    Write-Log -Message "Starting Logman" -Type "INFO"
    logman create trace "WinRM-Trace" -ow -o %0\..\WinRM-Trace-%COMPUTERNAME%.etl -p "Microsoft-Windows-WinRM" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 2048 -ets

    Write-Log -Message "Starting NetSh" -Type "INFO"
    netsh trace start maxSize=1024MB capture=yes tracefile= ("c:\temp\" + $env:COMPUTERNAME + ".etl")

    Write-Log -Message "Stopping WinRM" -Type "INFO"
    Stop-Service -Name "WinRM" -Force

    Write-Log -Message "Starting WinRM" -Type "INFO"
    Start-Service -Name "WinRM"

    if($IsSender -eq $true) {
        Write-Log -Message (Get-CurrentTime + " Starting Test-WSMan") -Type "INFO"
        $node = Read-Host -Prompt "Please enter the node that you want to test with"
        Test-WSMan -ComputerName $node
        Write-Log -Message (Get-CurrentTime + " Finished Test-WSMan") -Type "INFO"
    } else {
        $res = Read-Host -Prompt "Please press y once the sender is showing 'Finished Test-WSMan' "
    }


    Write-Log -Message "Stopping WinRM" -Type "INFO"
    Stop-Service -Name "WinRM" -Force

    Write-Log -Message "Stopping Logman" -Type "INFO"
    logman stop "WinRM-Trace" -ets
    
    Write-Log -Message "Stopping NetSh" -Type "INFO"
    netsh trace stop

    Write-Log -Message "Starting WinRM" -Type "INFO"
    Start-Service -Name "WinRM"
}





