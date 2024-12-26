$ErrorActionPreference="SilentlyContinue"
function TimeToRelString {
    param (
        [DateTime]$time
    )
    $rtime=(get-date)-$time;
    $rstring = ""
    $rdays = $rtime.Days
    $rhours = $rtime.Hours
    $rminutes = $rtime.Minutes
    if ($rdays) {
        $rstring += "$rdays days, "
    }
    if ($rhours) {
        $rstring += "$rhours hours, "
    }
    if ($rminutes) {
        $rstring += "$rminutes minutes, "
    }
    $rstring += "$($rtime.Seconds).$($rtime.Milliseconds) seconds"
    return $rstring
}
$starttime=(get-date);
$result=[System.Collections.ArrayList]@()

$cdpu=gsv|?{$_.name -like "CDPUserSvc_*"}
#processes to add maybe AggregatorHost WmiPrvSE taskhostw nvcontainer SearchHost StartMenuExperienceHost CHXSmartScreen SmartScreen OpenWith (maybe conhost consent )
$servicenames="AHCache","Appinfo","AUEPLauncher","BAM","BFE","CryptSvc","CTFMon","DiagTrack","Dnscache","DPS","DusmSvc","EventLog","Explorer","InventorySvc","MDCoreSvc","mpsdrv","mpssvc","Ndu","PcaSvc","PlugPlay","Schedule","SIHost","StorSvc","SysMain","volsnap","WdFilter","WdNisDrv","WinDefend","WSearch",$cdpu.Name
#other services $servicenames="AHCache","Appinfo","AUEPLauncher","BAM","BFE","CryptSvc","CTFMon","DiagTrack","Dnscache","DPS","DusmSvc","EventLog","Explorer","InventorySvc","MDCoreSvc","mpsdrv","mpssvc","Ndu","PcaSvc","PlugPlay","Schedule","SgrmAgent","SgrmBroker","SIHost","StorSvc","swprv","SysMain","vmicvss","volsnap","VSS","VSStandardCollectorService150","W32Time","WdBoot","WdFilter","WdNisDrv","WinDefend","WSearch"
write-host -f darkr "STARTING THE WMI REQUEST...`nIt should take less than 1 second; if the request takes too long, one or more services are likely suspended, or their main thread is suspended."
$services=gwmi win32_service|?{$_.name -in $servicenames};
if($services){
    write-host -f gre "WMI Request completed successfully!!"
}else{
    write-host -f r "The WMI Request returned no results. Information related to the services process will not be provided."
}
foreach($name in $servicenames){
    $ogg=[PSCustomObject]@{
        Name=$name;
        Status=$null;
        Type=$null;
        StartMode=$null;
        ProcessName=$null;
        PID=$null;
        StartTime=$null;
        RelStartTime=$null;
        "Suspended Threads"=$null;
    }
    $processo=$null;$service=$null;$wmisv=$null;
    write-host -f blu "Checking $name"
    $service=gsv $name;
    if($service){
        $ogg.StartMode=$service.StartType;
        $ogg.Status=$service.status;
        $wmisv=$services|?{$_.name -eq $name}
        if($wmisv){
            $ogg.Type="Service";
            if($ogg.Status -ne "Stopped"){
                $processo=ps -id $wmisv.ProcessId;
            }
        }else{
            $ogg.Type="Driver";
            $wmisv=$drivers|?{$_.name -eq $name}
        }
    }else{
        $processo=ps $name;
        if($processo){
            $ogg.Type="Process";
            $ogg.Status="Running";
            $ogg.StartMode="??"
        }else{
            write-host -f darkr "PROCESS $name NOT FOUND --> STOPPED OR UNEXISTING"
            $ogg.Type="Process";
            $ogg.Status="Stopped";
        }
    }


    if($processo){
        $ogg.PID=$processo.Id
        $ogg.ProcessName=$processo.Name;
        $ogg.StartTime=$processo.StartTime;
        $ogg.RelStartTime="Process has been running for "+(TimeToRelString $ogg.StartTime);
        $threads=$processo.Threads;
        $susthreads=$threads|?{$_.waitreason -eq "Suspended"}

        #confronto tra main thread name e process file name ecc..

        if($susthreads){
            $ids=$susthreads.id-join','
            write-host -f r "Found suspended threads for $name - $($ogg.ProcessName):",$susthreads.id;
            $ogg."Suspended Threads"=$susthreads.id
        }

        #write-host -f blu $name;
        #$threads|%{$_|select id,starttime,threadstate,waitreason,startaddress}|sort id|ft -a



        #$modules=$processo.Modules|?{$_.baseaddress.toint64() -gt 0}|select *,@{Name="EndAddress";Expression={$_.baseaddress.toint64()+$_.modulememorysize}}|sort baseaddress
        <#if(!$modules){write-host -f r "MODULES NOT FOUND"}
        $threads|%{
            $module=$null;$thread=$null;
            # aggiungere ricerca dicotomica con una sort
            $startaddress=$_.startaddress.toint64();
            if($startaddress -le 0){
                write-host "Startaddress del thread invalido: sa=$startaddress tid=$($_.id)"
            }
            $module=$modules|?{$startaddress -ge $_.baseaddress.toint64() -and $startaddress -le $_.endaddress}
            $thread=($_|select id,starttime,threadstate,waitreason,startaddress)
            if($module){
                $thread=$thread|select *,@{Name="ModuleName";Expression={"$($module.ModuleName)+$(($startaddress-$module.BaseAddress).ToString('x'))"}}
            }
            write-host $thread|ft -a
        }#>
    }
    $result.add($ogg)|Out-Null
}
$result=$result|sort starttime,status,type
#$result|ft -a
$result|ogv -t "SSITA Service Informer | Developed by KernelCore (https://discord.gg/ssita) | $("Elapsed Time: "+(TimeToRelString $starttime)) - $("Boot RelTime: "+(TimeToRelString (gcim Win32_OperatingSystem).LastBootUpTime))";
