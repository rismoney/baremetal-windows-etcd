function download-winbits {

# this can probably be cleaned up.  I wanted this to work first
# and then i can wrap Get-WebFile

  # create download folder if it doesnt exist
  if (-not(test-path -path $downloadfolder)) {
    mkdir $downloadfolder
  }

  #create mount folder if it doesnt exist
  if (-not(test-path -path $mountfolder)) {
    mkdir $mountfolder
  }


  #create adk folder if it does not exist
  if (-not(test-path -path "$downloadfolder\adk")) {
    mkdir "$downloadfolder\adk"
  }

  if (-not(test-path -path "$downloadfolder\adk\$adksetup")) {
    Get-WebFile "$adkMainURL$adksetup" "$downloadfolder\adk\$adksetup"
  }

  foreach ($h in $adklist.GetEnumerator()) {
    $adkname = $h.Value
    write-output "processing: $adkname"
    $adkfile = join-path "$downloadfolder\adk" $adkname
    if (-not(test-path -path "$adkfile")) {
      $adkurl = "$adkMainURL" + "Installers/" + $adkname
      write-output "getting: $adkurl"
      Get-WebFile $adkurl $adkfile
    }
    else {write-output "Skipping download $adkname"}
  }


  if (-not(test-path -path "$zip1file")) {Get-WebFile $zip1url $zip1file}
  else {write-output "Skipping download $zip1file"}

  if (-not(test-path -path "$zip2file")) {Get-WebFile $zip2url $zip2file}
  else {write-output "Skipping download $zip2file"}

  if (-not(test-path -path "$dhcptoolfile")) {Get-WebFile $dhcptoolurl $dhcptoolfile}
  else {write-output "Skipping download $dhcptoolfile"}

  }
