$ErrorActionPreference="SilentlyContinue"
cls
write-host -f red "███████╗███████╗██╗████████╗ █████╗     ██████╗  ██████╗ █████╗ ██████╗ ██████╗ 
██╔════╝██╔════╝██║╚══██╔══╝██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗
███████╗███████╗██║   ██║   ███████║    ██████╔╝██║     ███████║██║  ██║██████╔╝
╚════██║╚════██║██║   ██║   ██╔══██║    ██╔═══╝ ██║     ██╔══██║██║  ██║██╔══██╗
███████║███████║██║   ██║   ██║  ██║    ██║     ╚██████╗██║  ██║██████╔╝██████╔╝
╚══════╝╚══════╝╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝      ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝ "
write-host -n -f cyan "Made by ";write-host -f blue -n "Katoylla ";write-host -n -f cyan "for ";write-host -f red -n "SSITA";write-host -n "(";write-host -f red -n "https://discord.gg/ssita";write-host ")"
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
    if($curr[2] -match "^%"){
     Path=[System.IO.Path]::GetFullPath([System.Environment]::ExpandEnvironmentVariables($curr[2]))
    }else{Path=$curr[2]}
    FileDescription=$curr[3]
    SoftwareVendor=$curr[4]
    FileVersion=$curr[5]
    AmcacheProgramID=$curr[6]
    ExitCode=$curr[7]
  })
}
$res|ogv -t "PCA General DataBase Parser | Made by Katoylla for SSITA (https://discord.gg/ssita) | values parsed: $($res.count)" -passthru
