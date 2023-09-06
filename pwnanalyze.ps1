#/*$connections = Get-NetTCPConnection
#
#foreach ($connection in $connections) {
#    $port = $connection.LocalPort
#    $processId = $connection.OwningProcess
#
#    if ($port -ne 0 -and $processId) {
#        Write-Host "Port $port => PID: $processId"
#        Get-Process -Id $processId
#       Write-Host
#    }
#}

#$connections = Get-NetTCPConnection
#
#foreach ($connection in $connections) {
#    $port = $connection.LocalPort
#    $processId = $connection.OwningProcess
#
#    if ($port -ne 0 -and $processId) {
#        $process = Get-Process -Id $processId
#
#        Write-Host "Port $($port.ToString().PadRight(5)) => PID: $($processId.ToString().PadRight(6)) $($process.ProcessName)"
#    }
#}
while ($true) {
    # Get the TCP connections
    $connections = Get-NetTCPConnection

    # Iterate through the connections and display the output
    foreach ($connection in $connections) {
        $port = $connection.LocalPort
        $processId = $connection.OwningProcess

        if ($port -ne 0 -and $processId) {
            $process = Get-Process -Id $processId
            Write-Host "Port $($port.ToString().PadRight(5)) => PID: $($processId.ToString().PadRight(6)) $($process.ProcessName)"
        }
    }

    # Prompt the user for input
    $searchNumber = Read-Host "`nEnter a port number to search (or 'exit' to quit)"

    # Check if the user wants to exit
    if ($searchNumber -eq "exit") {
        break
    }

    # Convert the user input to an integer
    $searchNumber = $searchNumber -as [int]

    # Iterate through the connections again and search for the specified port
    $found = $false
    foreach ($connection in $connections) {
        $port = $connection.LocalPort
        $processId = $connection.OwningProcess

        if ($port -eq $searchNumber -and $processId) {
            $process = Get-Process -Id $processId

            # Highlight the user's input in red
            $portString = $port.ToString()
            $highlightedPort = $portString.Replace($searchNumber, "`e[31m$searchNumber`e[0m")

            Write-Host "Port $highlightedPort => PID: $($processId.ToString().PadRight(6)) $($process.ProcessName)"
            $found = $true
        }
    }

    # If no matching port was found, display a message
    if (-not $found) {
        Write-Host "No connections found for port $searchNumber"
    }

    # Add an empty line for separation
    Write-Host
}
