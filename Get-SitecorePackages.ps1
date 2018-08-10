[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "PasswordAuthenticationContext")]
Param(
  [Parameter(Position = 1, Mandatory = $true, HelpMessage = "dev.sitecore.net username")]
  [ValidateNotNullOrEmpty()]
  [Alias("Username")]
  [string]$SitecoreUsername,
  [Parameter(Position = 2, Mandatory = $true, HelpMessage = "dev.sitecore.net password")]
  [ValidateNotNullOrEmpty()]
  [Alias("Password")]
  [string]$SitecorePassword,
  [Parameter(Position = 3, Mandatory = $true, HelpMessage = "Destination path for packages")]
  [ValidateScript({ Test-Path $_ -PathType Container })]
  [string]$Destination
)
Begin {
  $eap = $ErrorActionPreference
  $vp = $VerbosePreference
  $ErrorActionPreference = "Stop"
  $VerbosePreference = "Continue"
}
Process {
  # Login to dev.sitecore.net
  $loginResponse = Invoke-WebRequest "https://dev.sitecore.net/api/authorization" -Method Post -Body @{
    username = $SitecoreUsername
    password = $SitecorePassword
    rememberMe  = $true
  } -SessionVariable "scSession" -UseBasicParsing
  If ($null -eq $loginResponse -or $loginResponse.StatusCode -ne 200) {
    Write-Error "Unable to login to dev.sitecore.net with the supplied credentials"
  }

  @(
    @{
      FileName = "Sitecore 9.0.2 rev. 180604 (WDP XPSingle packages).zip"
      Uri = "https://dev.sitecore.net/~/media/F53E9734518E47EF892AD40A333B9426.ashx"
    },
    @{
      FileName = "Web Forms for Marketers 9.0 rev. 180503.zip"
      Uri = "https://dev.sitecore.net/~/media/3BFEB7C427D040178E619522EA272ECC.ashx"
    }
  ) | ForEach-Object {
    $package = $_

    $outFile = Join-Path $Destination -ChildPath $package.FileName
    If (!(Test-Path $outFile)) {
      Invoke-WebRequest $package.Uri -OutFile $outFile -WebSession $scSession -UseBasicParsing
    }
  }
}
End {
  $ErrorActionPreference = $eap
  $VerbosePreference = $vp
}