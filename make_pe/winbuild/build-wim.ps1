function build-wim {

  write-output "Create the WinPE working folder"

  if (-not(test-path -path $winpefolder)) {
    mkdir $winpefolder
  }
  else {
    rename-item $winpefolder "$winpefolder-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
    mkdir $winpefolder
  }

  write-output "copy winpe wim to our working folder"
  $winpewim = "$adkfolder\Assessment and Deployment Kit\Windows Preinstallation Environment\$bitversion\en-us\winpe.wim"
  copy $winpewim $winpefolder

  write-output "mount the wim"
  try {
    $winpewim_file="$winpefolder\winpe.wim"
    & $dism /mount-image /imagefile:$winpewim_file /index:1 /MountDir:$mountfolder /optimize
  }
  catch {
    write-output "error mounting wim"
    exit 1
  }

    write-output "set the scratch space"
  try {
    $winpewim_file="$winpefolder\winpe.wim"
    & $dism /image:$mountfolder /set-scratchspace:128
	sleep 3
  }
  catch {
    write-output "error setting scratchspace"
    exit 1
  }

  write-output "#copy zip executable and dll"
  echo d | xcopy /S /Y "$downloadfolder\7z.exe" "$mountfolder\tools"
  echo d | xcopy /S /Y "$downloadfolder\7z.dll" "$mountfolder\tools"

  write-output "win pe startup scripts"
  echo d |xcopy /Y "$runtimefolder\startnet.cmd" "$mountfolder\Windows\System32"
  echo d |xcopy /Y "$runtimefolder\custom.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\image.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\network.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\post-script.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\prep-disk.ps1" "$mountfolder"
  echo d |xcopy /Y "$runtimefolder\tokenxml.ps1" "$mountfolder"

  echo d | xcopy /S /Y "$downloadfolder\dhcptest-0.5-win64.exe" "$mountfolder"

  write-output "#copy zip executable"
  write-output "add get-webfile to winpe"
  echo d |xcopy /Y "$winbuild\Get-WebFile.ps1" "$mountfolder\tools"

  write-output "add 3rd party drivers"
  if (test-path -path $driverfolder) {
    & $dism /image:$mountfolder /Add-Driver /Driver:"$driverfolder" /Recurse /ForceUnsigned
  }
  write-output "add packages"
  add-packages

  try {
    & $dism /unmount-image /mountdir:$mountfolder /commit
  }
  catch {
    write-output "error unmounting"
    exit 1
  }
}
