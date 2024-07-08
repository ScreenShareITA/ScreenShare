$res = [System.Collections.Generic.List[PSObject]]::new()
$raw = (gc "$env:windir\appcompat\pca\PcaGeneralDb0.txt") -split "\n"
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
