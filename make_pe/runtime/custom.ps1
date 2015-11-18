cd \
. .\network.ps1
. .\image.ps1
. .\tokenxml.ps1
. .\prep-disk.ps1

# get the dhcp scope option 12 via tool script since windows dhcp cannot get it on its own.
# reference : http://github.com/CyberShadow/dhcptest

# get the enabled ethernet 802.3 adapter
$macaddress = ((gwmi win32_networkadapter) | ? {($_.NetEnabled -eq $true) -and ($_.AdapterTypeID -eq 0)}).macaddress

write-host -Foregroundcolor magenta "Primary Mac Address: $macaddress"
$fqdn = X:\dhcptest-0.5-win64.exe --mac $macaddress --request 12 --query --print-only 12 --quiet
write-host  -Foregroundcolor magenta  "fqdn obtained via dhcp option 12: fqdn"
write-host "if the hostname is not correct please abort"


# get the build specs
mkdir X:\build

$branch = Invoke-WebRequest -Uri "http://puppet.inf.ise.com:8080/cgi-bin/branch.rb?ise_mock_fqdn=$fqdn"


 get unattend xml for targetos
Invoke-WebRequest -Uri "http://puppet.inf.ise.com:8080/cgi-bin/winbuild.rb?ise_mock_fqdn=$fqdn;build_branch=$branch" -outfile X:\build\unattend.xml

[xml]$xml = Get-Content X:\build\unattend.xml
$targetos = $xml.'#comment'[0]

# ready the target disk (diskpart, dirs, etc)
prep-disk $targetos

# download post script
Invoke-WebRequest -Uri "http://chocopackages.ise.com/windows/post-script.ps1" -outfile C:\@inf\winbuild\scripts\post-script.ps1

# apply image to target disk
Lay-Image $targetos

#save the branch for future puppet agent invocation
$branch |out-file C:\@inf\winbuild\scratch\buildbranch.txt
write-host "sleep for 15 seconds to press control-C"
sleep 15
