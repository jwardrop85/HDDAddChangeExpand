Set-WinSystemLocale -SystemLocale en-GB
Set-WinHomeLocation -GeoId 242
Set-WinUserLanguageList -LanguageList (New-WinUserLanguageList -Language en-GB) -Force
Set-Culture en-GB
exit 0