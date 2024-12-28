$ErrorActionPreference = "SilentlyContinue";
$starttime=(Get-Date);
$processi=Get-Process|Where-Object{$_.name -like "fivem*"};
if($processi){
    Write-Host -ForegroundColor Green "Found some processes executed :) Starting module compare for:",($processi.Name-join', ');
    $moduli=$processi.Modules|Sort-Object {$_.FileName.ToLower()};#order by filename but still have all info

    #Extracting dlls
    $dlls=(Invoke-RestMethod "https://raw.githubusercontent.com/Katoylla/ScreenShare/main/dllsus.txt") -split "\n";
    if(!$dlls){
        Write-Host -ForegroundColor Red "Failed to retrieve legit dlls list or splitting them by lines :(";
    }else{
        Write-Host -ForegroundColor Green "Found legit dlls list. Expanding enviroment variables...";
    }
    $dlllegit=$dlls|ForEach-Object{[System.Environment]::ExpandEnvironmentVariables($_).trim()};

    $i=0;
    $dim=$dlllegit.Count;
    Write-Host -ForegroundColor Green "Everything is ready. Let's start comparing :)";
    $moduletime=(Get-Date);
    $modulisus = foreach($modulo in $moduli){
        $pathmodulo=$modulo.FileName.ToLower();
        while($i -lt $dim -and $pathmodulo -gt $dlllegit[$i]){
            $i++;#scorro finche il dll legit attuale non sia uguale o maggiore di quello attuale per poi fare confronti sensati
        }
        if($pathmodulo -lt $dlllegit[$i]){
            Write-Host "$pathmodulo < $($dlllegit[$i])"
            $modulo#se è maggiore scarto (perchè arrivato alla fine dei legit scarta) e se è uguale scartiamo perchè vuoldire che è legit
        }
    }
    $endtime=Get-Date
    Write-Host -ForegroundColor Green "Finished checking :)`nModule check time --> $(($endtime-$moduletime).TotalMilliseconds/1000)`nTotal elapsed time --> $(($endtime-$starttime).TotalMilliseconds/1000)";
    if($modulisus){
        Write-Output $modulisus
        Write-Host -ForegroundColor Blue "Dll Sospetti:"
        Write-Output ($modulisus.filename.ToLower()|Sort-Object|Select-Object -Unique
        #|ForEach-Object{$_ -replace "\\$env:username\\","\%username%\"}
        )
    }else{
        Write-Host -ForegroundColor Blue "Didn't find any suspect module. Make sure the compared data is enough:`nChecked modules --> $($moduli.Count)`nLegit modules --> $dim";
    }
}else{
    Write-Host -ForegroundColor Red "No process found :( Exiting!";
}