$ErrorActionPreference = "SilentlyContinue";
$boot = (gcim Win32_OperatingSystem).LastBootUpTime;
function TimeRelToStartString {
    param ([DateTime]$time)
    return TimeConfrontString $time (Get-Date);
}
function TimeRelToBootString {
    param ([DateTime]$time)
    return TimeConfrontString ($boot) $time;
}
function TimeConfrontString {
    param(
        [DateTime]$time,
        [Datetime]$time2
        )
    $rtime=$time2-$time;
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
        "Process Name"="//";
        PID="//";
        "Start Time"="//";
        "Relative Start Time"="//";
        "Boot Relative Start Time"="//";
        "Suspended Threads"="//";
    }
    $processi = $null;$service=$null;$wmisv=$null;
    Write-Host -ForegroundColor blu "Checking $name"
    $service = Get-Service $name;
    if($service){
        $ogg."Start Mode"=$service.StartType;
        $ogg.Status=$service.status;
        $wmisv = $services| Where-Object {$_.name -eq $name}
        if($wmisv){
            $ogg.Type="Service";
            if($ogg.Status -ne "Stopped"){
                $processi = Get-Process -id $wmisv.ProcessId;
            }
        }else{
            $ogg.Type="Driver";
            $wmisv = $drivers|Where-Object{$_.name -eq $name}
        }
    }else{
        $processi = Get-Process $name;
        if($processi){
            $ogg.Type="Process";
            $ogg.Status="Running";
            $ogg."Start Mode"="??"
        }else{
            Write-Host -ForegroundColor DarkRed "PROCESS $name NOT FOUND --> STOPPED OR UNEXISTING"
            $ogg.Type = "Process";
            $ogg.Status = "Stopped";
        }
    }


    if($processi){
        $processi=$processi|Sort-Object StartTime
        $ogg.PID = $processi.Id-join"`n";
        $ogg."Process Name" = $processi.Name-join"`n";
        $ogg."Start Time" = $processi.StartTime-join"`n";
        $ogg."Relative Start Time" = ($processi|ForEach-Object{"Process has been running for "+(TimeRelToStartString $_.StartTime)})-join"`n"
        $ogg."Boot Relative Start Time" = ($processi|ForEach-Object{TimeRelToBootString $_.StartTime})-join"`n"
        $threads=$processi.Threads;
        $susthreads=$threads|Where-Object{$_.waitreason -eq "Suspended"}
        <#$processi|ForEach-Object{
            $m=$_.MainModule
            if($m){
                # description fileversionifo ecc.. also size in fileversion info original name ecc..
                $fl=$_.Path.tolower()
                $ofl=$m.Filename.tolower()
                Write-Host "$fl $ofl"
                if($fl -ne $ofl){
                    Write-Host -ForegroundColor Red "Filepath mismatch found:`nOriginal filepath --> $ofl`nCurrent filepath --> $fl"
                }
            }else{
                Write-Host -ForegroundColor Red "I'm not able to find the main module for $($_.Name)"
            }
        }#>

        if($susthreads){
            $ids = $susthreads.id-join', '
            Write-Host -ForegroundColor Red "Found suspended threads for $name - $($ogg."Process Name") $($susthreads.Count)/$($threads.Count):",$ids;
            $ogg."Suspended Threads" = $ids
        }

    }
    $result.add($ogg)|Out-Null
}
$result = $result|Sort-Object "Start Time",Status,Type
#$result|ft -a
$result|Out-GridView -Title "SSITA Service Informer | Developed by KernelCore (https://discord.gg/ssita) | Elapsed Time: $(TimeRelToStartString $starttime) - Boot RelTime: $(TimeRelToStartString $boot)";
Read-Host