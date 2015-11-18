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

