& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"UKRegion.xml`""
Set-WinSystemLocale -SystemLocale en-GB
Set-WinHomeLocation -GeoId 242
Set-WinUserLanguageList -LanguageList (New-WinUserLanguageList -Language en-GB) -Force
Set-Culture en-GB
$path = Split-Path -parent $PSCommandPath
$TempKey= "HKU\TEMP"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"
reg load $TempKey $DefaultRegPath
Get-ChildItem $path -Filter *.reg | % {
    Start-Process regedit -ArgumentList "/s `"$($_.FullName)`"" -Wait
}
reg unload $TempHKEY
exit 0