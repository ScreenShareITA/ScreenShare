$ErrorActionPreference = "SilentlyContinue";
function TimeToRelString {
    param ([DateTime]$time)
    $rtime=(Get-Date)-$time;
    $rstring = "";
    $rdays = $rtime.Days;
    $rhours = $rtime.Hours;
    $rminutes = $rtime.Minutes;
    if ($rdays) {
        $rstring += "$rdays days, ";
    }
    if ($rhours) {
        $rstring += "$rhours hours, ";
    }
    if ($rminutes) {
        $rstring += "$rminutes minutes, ";
    }
    $rstring += "$($rtime.Seconds).$($rtime.Milliseconds) seconds";
    return $rstring;
}
$starttime = (Get-Date);
$result = [System.Collections.ArrayList]@();

$cdpu = Get-Service|Where-Object{$_.Name -like "CDPUserSvc_*"};
#processes to add maybe AggregatorHost WmiPrvSE taskhostw nvcontainer SearchHost StartMenuExperienceHost CHXSmartScreen SmartScreen OpenWith (maybe conhost consent)
$servicenames = "AHCache","Appinfo","AUEPLauncher","BAM","BFE",$cdpu.Name,"CryptSvc","CTFMon","DiagTrack","Dnscache","DPS","DusmSvc","EventLog","Explorer","InventorySvc","MDCoreSvc","mpsdrv","mpssvc","Ndu","PcaSvc","PlugPlay","Schedule","SIHost","StorSvc","SysMain","volsnap","WdFilter","WdNisDrv","WinDefend","WSearch";
#other services too $servicenames="AHCache","Appinfo","AUEPLauncher","BAM","BFE","CryptSvc","CTFMon","DiagTrack","Dnscache","DPS","DusmSvc","EventLog","Explorer","InventorySvc","MDCoreSvc","mpsdrv","mpssvc","Ndu","PcaSvc","PlugPlay","Schedule","SgrmAgent","SgrmBroker","SIHost","StorSvc","swprv","SysMain","vmicvss","volsnap","VSS","VSStandardCollectorService150","W32Time","WdBoot","WdFilter","WdNisDrv","WinDefend","WSearch"
Write-Host -ForegroundColor DarkRed "STARTING THE WMI REQUEST...`nIt should take less than 1 second; if the request takes too long, one or more services are likely suspended, or their main thread is suspended."
$services = Get-WmiObject win32_service|Where-Object{$_.Name -in $servicenames};
if($services){
    Write-Host -ForegroundColor Green "WMI Request completed successfully!!"
}else{
    Write-Host -ForegroundColor Red "The WMI Request returned no results. Information related to the services process will not be provided."
}
foreach($name in $servicenames){
    $ogg = [PSCustomObject]@{
        Name=$name;
        Status=$null;
        Type=$null;
        "Start Mode"=$null;
        "Process Name"=$null;
        PID=$null;
        "Start Time"=$null;
        "Relative Start Time"=$null;
        "Suspended Threads"=$null;
    }
    $processo = $null;$service=$null;$wmisv=$null;
    Write-Host -ForegroundColor blu "Checking $name"
    $service = Get-Service $name;
    if($service){
        $ogg."Start Mode"=$service.StartType;
        $ogg.Status=$service.status;
        $wmisv = $services| Where-Object {$_.name -eq $name}
        if($wmisv){
            $ogg.Type="Service";
            if($ogg.Status -ne "Stopped"){
                $processo = Get-Process -id $wmisv.ProcessId;
            }
        }else{
            $ogg.Type="Driver";
            $wmisv = $drivers|Where-Object{$_.name -eq $name}
        }
    }else{
        $processo = Get-Process $name;
        if($processo){
            $ogg.Type="Process";
            $ogg.Status="Running";
            $ogg."Start Mode"="??"
        }else{
            Write-Host -ForegroundColor DarkRed "PROCESS $name NOT FOUND --> STOPPED OR UNEXISTING"
            $ogg.Type = "Process";
            $ogg.Status = "Stopped";
        }
    }


    if($processo){
        $ogg.PID = $processo.Id;
        $ogg."Process Name" = $processo.Name;
        $ogg."Start Time" = $processo.StartTime;
        $ogg."Relative Start Time" = "Process has been running for "+(TimeToRelString ($ogg."Start Time")[0]);
        $threads=$processo.Threads;
        $susthreads=$threads|Where-Object{$_.waitreason -eq "Suspended"}

        #confronto tra main thread name e process file name ecc..

        if($susthreads){
            $ids = $susthreads.id-join','
            Write-Host -ForegroundColor Red "Found suspended threads for $name - $($ogg."Process Name"):",$ids;
            $ogg."Suspended Threads" = $ids
        }

    }
    $result.add($ogg)|Out-Null
}
$result = $result|Sort-Object starttime,status,type
#$result|ft -a
$result|Out-GridView -Title "SSITA Service Informer | Developed by KernelCore (https://discord.gg/ssita) | $("Elapsed Time: "+(TimeToRelString $starttime)) - $("Boot RelTime: "+(TimeToRelString (gcim Win32_OperatingSystem).LastBootUpTime))";
