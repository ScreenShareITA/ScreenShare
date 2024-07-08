$ErrorActionPreference="SilentlyContinue"
cls
write-host -f red "
 ____  ____  __  ____  __     ____   ___   __   ____  ____ 
/ ___)/ ___)(  )(_  _)/ _\   (  _ \ / __) / _\ (    \(  _ \
\___ \\___ \ )(   )( /    \   ) __/( (__ /    \ ) D ( ) _ (
(____/(____/(__) (__)\_/\_/  (__)   \___)\_/\_/(____/(____/"
write-host -n "Made by ";write-host -f blue -n "Katoylla ";write-host -n "for ";write-host -f red -n "SSITA";write-host -n "(";write-host -f red -n "https://discord.gg/ssita";write-host ")"
$res = [System.Collections.Generic.List[PSObject]]::new()
$p="$env:windir\appcompat\pca\PcaGeneralDb0.txt"
if(!(test-path $p)){
  write "File non trovato nella path: $p"
  if(test-path "$env:windir\appcompat\pca"){
    write "Cartella pca trovata verifica se i file sono stati eliminati o ne è stato modificato il nome"
  }else{
    write "Cartella pca non presente. Probabilmente dipende dal pc dell'utente prosegui con l'ss"
  }
  exit
}
$raw = (gc $p -raw) -split "\r?\n"
$raw|%{
  $curr=$_ -split "\|";
  $res.add([pscustomobject]@{
    ExecutionTime=$curr[0]
    RunStatus=$curr[1]
    Path=$curr[2]
    FileDescription=$curr[3]
    SoftwareVendor=$curr[4]
    FileVersion=$curr[5]
    AmcacheProgramID=$curr[6]
    ExitCode=$curr[7]
  })
}
$res|ogv -t "PCA General DataBase Parser | Made by Katoylla for SSITA (https://discord.gg/ssita) | values parsed: $($res.count)" -passthru
