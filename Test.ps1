Set-Location $PSScriptRoot
. .\MyVPA-API.ps1
. .\config.ps1

$vpa = Enter-MYVPA -User $myVPAUsername -Password $myVPAPassword

$taskReference = "25Chars"
$Description = "Multiline
task
description
"

Add-MYVPATask -MyVPABrowser $vpa -MaxHours 1 -TaskReference25 $taskReference -Description $Description


Exit-MYVPA $vpa
