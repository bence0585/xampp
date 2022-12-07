<#
  .Synopsis
  Letölt és telepít egy MSI csomagot.
  .Description
  Letölt egy MSI csomagot és halktelepíti a host gépen. Minden rendszer
  PATH válozás a telepítő után alkalmazódik. Plusz, megpróbálhatja észlelni
  a letelepített alkalmazást.

  .Parameter Name
  A csomag neve.

  .Parameter Url
  A letöltendő csomag URL-je.

  .Parameter NoVerify
  Ha be van állítva, a telepítő nem próbája észlelni a letelepített alkalmazást.

  .Parameter Options
  Telepítési opciók.
#>
function Install-FromExe {
    param(
        [Parameter(Mandatory)]
        [string]$name,
        [Parameter(Mandatory)]
        [string]$url,
        [Parameter()]
        [switch]$noVerify = $false,
        [Parameter(Mandatory)]
        [string[]]$options = @()
    )

    $installerPath = Join-Path ([System.IO.Path]::GetTempPath()) ('{0}.exe' -f $name);

    Write-Information -MessageData ('{0} telepito letoltese a {1} url-rol ..' -f $name, $url) -InformationAction Continue;
    . .\Invoke-WebFileRequest.ps1
    Invoke-WebFileRequest -url $url -DestinationPath $installerPath;
    Write-Information -MessageData ('{0} byte letoltve' -f (Get-Item $installerPath).Length) -InformationAction Continue;

    Write-Information -MessageData ('{0} Telepitese ...' -f $name) -InformationAction Continue;
    Write-Information -MessageData ('{0} {1}' -f $installerPath, ($options -join ' ')) -InformationAction Continue;

    Start-Process $installerPath -Wait -ArgumentList $options;

    # PATH Frissítése ...

    . .\Update-ScriptPath;
    Update-ScriptPath;
    if (!$noVerify) {
        Write-Information -MessageData ('{0} ellenorzese ...' -f $name) -InformationAction Continue;
        $verifyCommand = (' {0} --version' -f $name);
        Write-Information -MessageData $verifyCommand -InformationAction Continue;
        Invoke-Expression $verifyCommand;
    }

    Write-Information -MessageData ('{0} telepitojenek eltavolitasa ...' -f $name) -InformationAction Continue;
    Remove-Item $installerPath -Force;
    . .\Remove-TempFiles.ps1
    Remove-TempFiles;

    Write-Information -MessageData ('{0} telepítés kész.' -f $name) -InformationAction Continue;
}