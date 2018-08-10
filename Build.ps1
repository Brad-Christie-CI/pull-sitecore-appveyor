[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)]
  [ValidateScript( {Test-Path $_ -PathType 'Container'})] 
  [string]$InstallSourcePath
)
$ErrorActionPreference = "Stop"

Get-ChildItem ".\sitecore" -Include "Dockerfile" -Recurse | ForEach-Object {
  Write-Verbose "Dockerfile: $($_.FullName)"
  $dockerfile = $_
  $imagePath = $_.FullName
  $imageFolder = $_.DirectoryName

  $buildFile = Join-Path $dockerfile.DirectoryName -ChildPath "build.json"
  If (Test-Path $buildFile -PathType Leaf) {
    $buildJson = Get-Content $buildFile | ConvertFrom-Json
    $buildJson.sources | ForEach-Object {
      $source = $_

      $sourceFile = Join-Path $InstallSourcePath -ChildPath $source
      If (!(Test-Path $sourceFile)) {
        Write-Error "Source file '$($sourceFile)' does not exist"
      }
      $destinationFile = Join-Path $imageFolder -ChildPath $source
      If (!(Test-Path $destinationFile -PathType Leaf)) {
        Copy-Item $sourceFile -Destination $destinationFile
      }
    }

    docker build --tag $buildJson.tag $imageFolder
  }
}