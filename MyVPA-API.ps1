Import-Module Selenium

function Enter-MYVPA {
    <#
        .SYNOPSIS
        Bei MyVPA anmelden

        .DESCRIPTION
        Öffnet die Oberfläche von myVPA und meldet den angegebenen Benutzer an.
        Gibt eine Selenium-Session zurück, damit man die Anwendung dann verwenden kann.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$User,
        [Parameter(Mandatory=$true)]
        [string]$Password
    )

    Process {
        $browser = Start-SeChrome -StartURL "https://app.my-vpa.com" -Maximized

        $usernameElement = Get-SeElement -By Id -Selection "username" -Target $browser
        Send-SeKeys -Element $usernameElement $user

        $passwordElement = Get-SeElement -By Id -Selection "password" -Target $browser
        Send-SeKeys -Element $passwordElement $password

        $login = Get-SeElement -By Id -Selection "kc-login" -Target $browser
        Send-SeClick -Element $login

        Start-Sleep -Seconds 5

        $browser
    }
}

function Exit-MYVPA {
    <#
        .SYNOPSIS
        Beendet die MyVPA-Session und schließt den Browser
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [PSObject]$MyVPABrowser
    )

    Process {
        Stop-SeDriver $myVPABrowser
    }
}

function ConvertTo-MYVPAJsString {
    <#
        .SYNOPSIS
        Formt die Eingabezeichenkette für eine Nutzung in Javascript um
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$InputString
    )
    
    Process {
        $result = $InputString
        $result = $result.Replace("`"", "'")
        $result = $result.Replace("'", "\'")
        $result = $result.Replace("`r", "")
        $result = $result.Replace("`n", "\n")
        return $result
    }
}

function Send-MYVPAChatInputString {
    <#
        .SYNOPSIS
        Gibt deinem My-VPA eine neue Aufgabe.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [PSObject]$MyVPABrowser,
        [Parameter(Mandatory=$true)]
        [string]$Content
    )

    Process {
        $ConvertedContent = ConvertTo-MYVPAJsString $Content

        $myVPABrowser.ExecuteScript("
            document.getElementById('chat-input-string').value = '$ConvertedContent';
        ");

        $Element = Get-SeElement -Id "chat-input-string" -Target $MyVPABrowser
        Send-SeKeys -Element $Element -Keys "`n"
    }
}

function Add-MYVPATask {
    <#
        .SYNOPSIS
        Gibt deinem My-VPA eine neue Aufgabe.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [PSObject]$MyVPABrowser,
        [Parameter(Mandatory=$true)]
        [string]$TaskReference25,
        [Parameter(Mandatory=$true)]
        [string]$Description,
        [Parameter(Mandatory=$true)]
        [int]$MaxHours
    )

    Process {
        Enter-SeUrl -Url "https://app.my-vpa.com/tasks/wizzard" -Target $myVPABrowser
        Start-Sleep -Seconds 5

        Send-MYVPAChatInputString -MyVPABrowser $MyVPABrowser -Content $Description
        Start-Sleep -Seconds 3
        $vpa.ExecuteScript('$("button:contains(''Nein'')").click()')
        Start-Sleep -Seconds 3
        Send-MYVPAChatInputString -MyVPABrowser $MyVPABrowser -Content $TaskReference25
        Start-Sleep -Seconds 3

        $myVPABrowser.ExecuteScript("
            document.getElementById('chat-input-budgetHours').value = '$MaxHours';
        ");
        Start-Sleep -Seconds 3
        $myVPABrowser.ExecuteScript('$("button[title=''Absenden'']").click()')
        Start-Sleep -Seconds 3
        $myVPABrowser.ExecuteScript('$("button[title=''Absenden'']").click()')
        Start-Sleep -Seconds 5
    }
}
