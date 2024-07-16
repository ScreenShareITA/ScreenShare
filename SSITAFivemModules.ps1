$fp=ps|?{$_.name -like "fivem*"}
$fd=$fp|%{ps -id $_.id -m}
$dlls=(irm https://raw.githubusercontent.com/Katoylla/ScreenShare/main/dllsus.txt) -split "\n"
$normdll=$dlls|%{[System.Environment]::ExpandEnvironmentVariables($_)}
$sus=$fd|?{$_.filename -notin $normdll}
write $sus
