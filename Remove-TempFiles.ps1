<#
  .Synopsis
    Átmeneti fájlokat töröl

  .Example
    Remove-TempFiles
#>
function Remove-TempFiles {
    $tempFolders = @($env:temp, 'C:/Windows/temp')

    Write-Information -MessageData 'Atmeneti fajlok eltavolitasa' -InformationAction Continue;
    $attempts = 1;
    $maxAttempts = 5;
    $filesRemoved = 0;
    $sleepFor = 1.0;
    $sleepMultiplier = 2.5;

    while ($true) {
        $couldNotRemove = @();

        foreach ($folder in $tempFolders) {
            $files = Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue $folder;

            foreach ($file in $files) {
                try {
                    Remove-Item $file.FullName -Recurse -Force -ErrorAction Stop;
                    $filesRemoved++;
                }
                catch {
                    $couldNotRemove += $file.FullName;
                }
            }
        }

        # Lépjen ki az ismétlésből, ha nem volt hiba
        if ($couldNotRemove.Count -eq 0) {
            Write-Information -MessageData ('osszes atmeneti fajl eltavolitva.') -InformationAction Continue;
            break;
        }

        Write-Information -MessageData ('{0} atmeneti fajlt nem sikerult eltavolitani.' -f $couldNotRemove.Count) -InformationAction Continue;

        # Kilépés az ismétlésből, ha elérte a max próbákat
        if ($attempts -eq $maxAttempts) {
            break;
        }

        Write-Information -MessageData ('{0} masodperc a kovetkező probaig.' -f $sleepFor) -InformationAction Continue;
        Start-Sleep -Seconds $sleepFor;

        $attempts += 1;
        $sleepFor *= $sleepMultiplier;
        Write-Information -MessageData ('Proba {0}/{1}' -f $attempts, $maxAttempts) -InformationAction Continue;
    }

    Write-Information -MessageData ('{0} atmeneti fajl eltavolitva.' -f $filesRemoved) -InformationAction Continue;
}