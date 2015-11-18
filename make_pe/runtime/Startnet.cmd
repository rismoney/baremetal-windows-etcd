wpeinit
REM see http://technet.microsoft.com/en-us/library/cc766390(v=ws.10).aspx
REM drvload will add out of box drivers

for /f %%F in ('dir /s /b /OD x:\windows\inf\oem*.inf') do drvload %%F
set path=X:\windows\system32;X:\Windows\System32\WindowsPowerShell\v1.0

Powershell.exe -ExecutionPolicy Unrestricted x:\custom.ps1

exit
