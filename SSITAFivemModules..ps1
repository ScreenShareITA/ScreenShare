$fp=ps|?{$_.name -like "fivem*"}
$fd=$fp|%{ps -id $.id}
write $fd
