# WinRM Trace collection
Super simple WinRM trace coll

## What will this script collect?
The script will collect
- Hostname (And if the host was used as a sender or receiver)
- WinRM Configuration
- Network Traffic using netsh (Only during the time the test is run)
- WinRM Traffic using logman (Only during the time the test is run)


## How to use it?
Please use the following instructions to setup the test.
1.	Download the file and copy it to 2 servers
1.	Rename the file on both servers to remove the `.txt` (After renaming you should have a `XXX.ps1` file)
1.	On one server, you will setup the tracing as a “receiver”
    1. Start the script and enter the full file path. In this scenario we will use `C:\temp\winrm` (Note: Ensure that the path exists. Otherwise this will fail and don’t include the last `\` in the path)
    1. Press `N` as you do not want to set it up as a sender at this point.
    1. Once you see the message “Please press any key once the sender is showing ‘Finished Test-WSMan’” continue to setup the sender on the other node
1.	On the other server you will setup the tracing as a “sender”
    1. Start the script and enter the full file path. In this scenario we will use `C:\temp\winrm` (Note: Ensure that the path exists. Otherwise this will fail and don’t include the last `\` in the path)
    1. Press `Y` as you now want to send test winrm data to the other host
    1. Now enter the hostname / ip address of the sender (The server that you setup in point 3)
    1. It will automatically start the testing process and you should be able to see `XXX Finished Test-WSMan`.
1.	Now navigate back to the server that was setup as a sender and press any key to stop the tracing
1.	You can now ZIP the folder that you chose in the beginning (In our case: `C:\temp\winrm`)

## Output Generated
| Filename                      | What it does                                                      |
| ------------------------------|-------------------------------------------------------------------|
| XXX-WinRM-Config-Dump.txt     | Configuration of WinRM                                            |
| XXX-WinRM-Logman-trace.etl    | Logman WinRM trace                                                |
| XXX-WinRM-Network-trace.cab   | Logman Network data                                               |
| XXX-WinRM-Network-trace.etl   | Logman Network trace                                              |
| XXX-WinRM-Trace-Log.log       | PowerShell log and timestamps of command execution incl. fractals.|