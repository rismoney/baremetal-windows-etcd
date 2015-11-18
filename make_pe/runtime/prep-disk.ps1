function prep-disk {

  Param(
    [string]$targetos
  )

  Invoke-WebRequest -Uri "http://chocopackages.ise.com/windows/$targetos/diskpart.txt" -outfile X:\build\diskpart.txt
  # make the cd-rom drive E:
  (gwmi win32_cdromdrive).drive | %{$a = mountvol $_ /l;mountvol $_ /d;$a = $a.Trim();mountvol e: $a}

  diskpart /s X:\build\diskpart.txt
  mkdir C:\@inf
  mkdir C:\@inf\winbuild
  mkdir C:\@inf\winbuild\scratch
  mkdir C:\@inf\winbuild\packages
  mkdir C:\@inf\winbuild\scripts
  mkdir C:\@inf\winbuild\logs
}