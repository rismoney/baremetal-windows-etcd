function Lay-Image {

  Param(
    [string]$targetos
  )

  write-host "deploying $targetos"
  switch ($targetos) {
    'win2008' {$image_no = '1'} #standard edition 2008
    'win2012' {$image_no = '2'} #standard edition 2012 R2
    'win7'    {$image_no = '1'} # enterprise edition image on win7
    default   {$image_no = '1'}
  }
  #get-webfile has status bar so we use it for big file download
  . X:\tools\Get-WebFile.ps1
  get-webfile "http://chocopackages.ise.com/windows/$targetos/install.wim" c:\@inf\winbuild\packages\install.wim

  # apply image to C: partition
  x:\windows\system32\Dism.exe /apply-image /imagefile:C:\@inf\winbuild\packages\install.wim /index:$image_no /ApplyDir:C:\

  # place unattend file in expected sysprep location
  copy "X:\build\unattend.xml" c:\windows\system32\sysprep\unattend.xml
  Write-Host "The target OS is '$targetos'"

  #fetch post first boot -script
  get-webfile "http://chocopackages.ise.com/windows/post-script.ps1" C:\@inf\winbuild\scripts
  mkdir C:\windows\setup\Scripts

  #config bootmenu
  bcdboot C:\windows
  Write-Host "Rebooting in 10 seconds.. control-c to troubleshoot interactively"
  sleep 10
}
