@ECHO OFF

set buffer=%1
if ""%1""=="""" set buffer=new
emacsclient.exe ^
    --alternate-editor runemacs.exe ^
    -f %APPDATA%\.emacs.d\files-%USERDOMAIN%-%USERNAME%\server ^
    %buffer%
