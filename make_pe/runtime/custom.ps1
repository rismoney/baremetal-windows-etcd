cd \
. .\network.ps1 # disables all adapters except "eth0"
. .\prep-disk.ps1 # diskpart/mkdir functionality
. .\image.ps1 # OS lay-image function

# get the enabled ethernet 802.3 adapter
$macaddress = ((gwmi win32_networkadapter) | ? {($_.NetEnabled -eq $true) -and ($_.AdapterTypeID -eq 0)}).macaddress

write-host -Foregroundcolor magenta "Primary Mac Address: $macaddress"
# get dhcp scope option 12 via open source tool (http://github.com/CyberShadow/dhcptest)
$fqdn = X:\dhcptest-0.5-win64.exe --mac $macaddress --request 12 --query --print-only 12 --quiet
write-host  -Foregroundcolor magenta  "fqdn obtained via dhcp option 12: $fqdn"
write-host "if the hostname is not correct please abort"

# get the build specs
mkdir X:\build
$branch = (Invoke-WebRequest -Uri "http://puppet.inf.ise.com:8080/cgi-bin/branch.rb?ise_mock_fqdn=$fqdn" -usebasicparsing).content


# fetch unattend.xml for fqdn and branch
Invoke-WebRequest -Uri "http://puppet.inf.ise.com:8080/cgi-bin/winbuild.rb?ise_mock_fqdn=$fqdn;build_branch=$branch" -outfile X:\build\unattend.xml
[xml]$xml = Get-Content X:\build\unattend.xml
if ($xml.'#comment' -is [system.array]) {
  $targetos = $xml.'#comment'[0]
}
else {
  $targetos = $xml.'#comment'.trim()
}
prep-disk $targetos
Lay-Image $targetos

# download post script
Invoke-WebRequest -Uri "http://chocopackages.ise.com/windows/post-script.ps1" -outfile C:\@inf\winbuild\scripts\post-script.ps1

if ($targetos -eq 'win2008') {
  if ($xml.'#comment'[1] -eq 'enterprise') {
    # touch a file to flag for enterprise edition
    New-Item -ItemType file C:\@inf\winbuild\scratch\enterprise.txt
  }
}

#save the branch for future puppet agent invocation
$branch |out-file C:\@inf\winbuild\scratch\buildbranch.txt
write-host "sleep for 5 seconds to press control-C"
sleep 5

