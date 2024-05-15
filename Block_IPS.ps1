# Function to get all existing firewall rules
function Get-FirewallRules {
    param ($searchWord)
    if (!$searchWord) {
        $rules = New-Object System.Collections.ArrayList
        Get-NetFirewallRule | ForEach-Object {$rules.Add($_) > $null}
        return $rules
    } else {
        $rules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*$searchWord*"}
        return $rules
    }
}

# Function to create a new firewall rule
function New-FirewallRule {
    param ($ruleName, $ipAddresses)
    foreach ($ipAddress in $ipAddresses) {
        $inboundRule = New-NetFirewallRule -Direction Inbound -Action Block -Protocol Any -RemoteAddress $ipAddress -DisplayName "$ruleName-Inbound-$ipAddress"
        $outboundRule = New-NetFirewallRule -Direction Outbound -Action Block -Protocol Any -RemoteAddress $ipAddress -DisplayName "$ruleName-Outbound-$ipAddress"
    }
    Write-Host "Firewall rule '$ruleName' created successfully! Blocked IP Addresses: $($ipAddresses -join ', ')" -ForegroundColor Green
}

# Interactive menu
while ($true) {
    Clear-Host
    Write-Host "Windows Firewall Manager" -ForegroundColor Yellow
    Write-Host "------------------------"
    Write-Host "1. List All Firewall Rules"
    Write-Host "2. Search Rules By Word"
    Write-Host "3. Create New Rule (Block Multiple IP Addresses)"
    Write-Host "4. Exit"

    $choice = Read-Host "Enter your choice [1/2/3/4]"

    switch ($choice) {
        1 {
            # List all firewall rules
            Write-Host "Existing Firewall Rules:" -ForegroundColor Cyan
            Get-FirewallRules | Select-Object DisplayName, Direction, Action, RemoteIPAddress | Format-Table -AutoSize
            Read-Host "Press Enter to continue..."
        }
        2 {
            # Search rules by word
            $searchWord = Read-Host "Enter a word to search for in rule names"
            Write-Host "Search Results ('$searchWord'):" -ForegroundColor Cyan
            Get-FirewallRules -searchWord $searchWord | Select-Object DisplayName, Direction, Action, RemoteIPAddress | Format-Table -AutoSize
            Read-Host "Press Enter to continue..."
        }
        3 {
            # Create new rule
            $ruleName = Read-Host "Enter the name for this rule"
            $ipAddresses = @()
            while ($true) {
                $ipAddress = Read-Host "Enter an IP address to block (or press enter to finish)"
                if (!$ipAddress) { break }
                $ipAddresses += $ipAddress
            }
            New-FirewallRule -ruleName $ruleName -ipAddresses $ipAddresses
            Read-Host "Press Enter to continue..."
        }
        4 {
            # Exit
            Write-Host "Goodbye!"
            exit
        }

        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Milliseconds 1000
        }
    }
}
