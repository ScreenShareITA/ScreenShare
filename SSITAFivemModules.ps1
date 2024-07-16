$fp=ps|?{$_.name -like "fivem*"}
$fd=$fp|%{ps -id $_.id -m}
$dlls=(irm https://raw.githubusercontent.com/Katoylla/ScreenShare/main/dllsus.txt) -split "\n"
$normdll=$dlls|%{[System.Environment]::ExpandEnvironmentVariables($_).trim()}
$sus=@()
$fd|%{
    $path=$_.FileName
    $notin=$true
    $normdll|%{
        if($path -ceq $_){
            $notin=$false
        }
    }
    if($notin){
        $sus+=$_
    }
}
write $sus
