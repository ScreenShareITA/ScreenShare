$res=@()
$dt=gci "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.ZuneMusic_8wekyb3d8bbwe\PersistedStorageItemTable\ManagedByApp"
$dt|%{
  $path=$_.GetValue('FilePath')
  $res+=[pscustomobject]@{
    Path=$path;
    Date=[DateTime]::FromFileTime([Convert]::ToInt64((($_.GetValue('LastUpdatedTime')|% { "{0:X2}" -f $_ })[-1..-8] -join '') , 16));
    Source=$_.Name
  }
}
$res|ogv -t "ZuneMusic Artifact Parser | Made by Katoylla for SSITA (https://discord.gg/ssita) | values parsed: $($res.count)" -passthru
