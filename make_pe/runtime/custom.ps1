#disable all IB adapters
$ib_adapters = gwmi -class win32_networkadapter | where-object {$_.servicename -eq 'ipoib6x'}
$ib_adapters | foreach {$_.disable()}

#disable all nics except "Ethernet"  or Port 1 windows 2012 is deterministic...
# this is done to ensure the primary adapter ties back to the DHCP reservatoin
$disconnected_adapters = gwmi -class win32_networkadapter |where-object {($_.netconnectionstatus -eq '7')}
$nonprimary_adapters   = gwmi -class win32_networkadapter |where-object  {((($_.NetConnectionID -notmatch "Port 1") -and ($_.NetConnectionID -ne "Ethernet")) -and ($_.netenabled -eq $true))}
write-host "The following are disconnected adapters:"
$disconnected_adapters  | select netconnectionid
write-host "The following are non primary adapters:"
$nonprimary_adapters  | select netconnectionid

$disconnected_adapters | foreach {$_.disable()}
$nonprimary_adapters | foreach {$_.disable()}
# we get the dhcp scope option 12 via tool script since windows dhcp cannot get it on its own.
# reference : http://github.com/CyberShadow/dhcptest
$macaddress = ((gwmi win32_networkadapter) | ? {($_.NetEnabled -eq $true) -and ($_.AdapterTypeID -eq 0)}).macaddress
write-host -Foregroundcolor magenta "Primary Mac Address: $macaddress"

$hostname = X:\dhcptest-0.5-win64.exe --mac $macaddress --request 12 --query --print-only 12 --quiet
write-host  -Foregroundcolor magenta  "Hostname obtained via dhcp option 12: $hostname"
write-host "if the hostname is not correct please abort"

$env:ise_kickstarting="yes"


# we will pause for 5 seconds waiting for user input.  If a key is pressed we will allow the user
# to manually type a branch name.  If no branch is provided, we will be using production.

#start of branch selection routine
$timer = 30
$i = 1

Do {
  Write-host -ForeGroundColor green -noNewLine "Press any key in $($timer-$i) seconds to enter a branch name"
  $pos = $host.UI.RawUI.get_cursorPosition()
  $pos.X = 0
  $host.UI.RawUI.set_cursorPosition($Pos)
  if($host.UI.RawUI.KeyAvailable) {
    $Host.UI.RawUI.FlushInputBuffer()
    write-output ""
    $branch= Read-Host "Please enter the branch you would like to build against"
    $timer=-1
  }
start-Sleep -Seconds 1

$i++
}While ($i -le $timer)

if (!$branch) {$branch = "production"}
# end of branch selection routine

# replace script below after cgi imported
X:\post-puppet.ps1

#save branch name to disk for later consumption
$branch |out-file C:\@inf\winbuild\scratch\buildbranch.txt
