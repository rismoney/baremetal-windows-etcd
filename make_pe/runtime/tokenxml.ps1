function Tokenize-XML {

Param(
  [string]$hostname,
  [string]$targetos,
  [string]$joindomain,
  [string]$ou,
  [string]$domain,
  [string]$username,
  [string]$password
)

  [xml]$xml = Get-Content X:\build\unattend.xml

  $shellsetup = $xml.unattend.settings.component | ? {$_.ComputerName -eq "ComputerName"}
  $shellsetup.ComputerName = $hostname

  $shellsetup = $xml.unattend.settings.component.Identification | ? {$_.JoinDomain -eq 'JoinDomain'}
  $shellsetup.JoinDomain = $joindomain

  $shellsetup = $xml.unattend.settings.component.Identification | ? {$_.MachineObjectOU -eq "MachineObjectOU"}
  $shellsetup.MachineObjectOU = $ou

  $xml.unattend.settings.Component.Identification.Credentials.Domain = $domain
  $xml.unattend.settings.Component.Identification.Credentials.Password = $password
  $xml.unattend.settings.Component.Identification.Credentials.Username = $username
  $xml.save("X:\build\unattend.xml")
}
