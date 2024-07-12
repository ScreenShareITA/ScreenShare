$ErrorActionPreference="SilentlyContinue"
function write-title(){
cls
write-host -f red "███████╗███████╗██╗████████╗ █████╗     ██████╗  ██████╗ █████╗ ██████╗ ██████╗ 
██╔════╝██╔════╝██║╚══██╔══╝██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗
███████╗███████╗██║   ██║   ███████║    ██████╔╝██║     ███████║██║  ██║██████╔╝
╚════██║╚════██║██║   ██║   ██╔══██║    ██╔═══╝ ██║     ██╔══██║██║  ██║██╔══██╗
███████║███████║██║   ██║   ██║  ██║    ██║     ╚██████╗██║  ██║██████╔╝██████╔╝
╚══════╝╚══════╝╚═╝   ╚═╝   ╚═╝  ╚═╝    ╚═╝      ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝ "
write-host -n -f cyan "Fatto da ";write-host -f blue -n "Katoylla ";write-host -n -f cyan "per ";write-host -f red -n "SSITA";write-host -n " (";write-host -f red -n "https://discord.gg/ssita";write-host ")"
}
write-title
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
$raw=gc $p -en Unicode
$cs=@()
$cp=@()
$raw|%{
  $curr=$_ -split "\|";
  $p=[System.Environment]::ExpandEnvironmentVariables($curr[2])
  $n=split-path -le $p
  write-host -n ("Verifica firma digitale per "+$p)
  $pos=$cp.indexof($p)
  if($pos -eq -1){
    if(test-path $p){
        if(test-path -patht leaf $p){
            $f=(get-authenticodesignature $p).status
        }else{
            $f="La path punta a una cartella"
        }
    }else{
        $f="Path non trovata"
    }
    $cp+=$p
    $cs+=$f
    write-host -f red " Nuovo file elaborato, numero di file trovati fino ad adesso --> $($cp.count)"
  }else{
    write-host -f red " File già elaborato in precedenza, ottimizzata la fase di controllo"
    $f=$cs[$pos]
  }
  $res.add([pscustomobject]@{
    ExecutionTime=$curr[0]
    DigitalSignature=$f
    FileName=$n
    Path=$p
    FileDescription=$curr[3]
    SoftwareVendor=$curr[4]
    FileVersion=$curr[5]
    AmcacheProgramID=$curr[6]
    ExitCode=$curr[7]
    RunStatus=$curr[1]
  })
}
write-title
for($i=0;$i -lt $cp.count;$i++){
    write-host -n ($cp[$i]+" | ")
    write-host -f red $cs[$i]
}
$res|ogv -t "PCA DataBase Parser | Made by Katoylla for SSITA (https://discord.gg/ssita) | values parsed: $($res.count) | files parsed: $($cp.count) " -passthru
