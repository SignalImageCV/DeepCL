cd jenkins
for /f "" %%i in (version.txt) do (
   set version=%%i
)
cd ..

powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://deepcl.hughperkins.com/Downloads/turbojpeg-1.4.0-win32-static.zip', 'turbojpeg-win32.zip')
if errorlevel 1 exit /B 1
mkdir turbojpeg-win32
cd turbojpeg-win32
"c:\program files\7-Zip\7z.exe" x ..\turbojpeg-win32.zip
if errorlevel 1 exit /B 1

dir
rmdir /s /q build
mkdir build
cd build
dir
"c:\program files (x86)\cmake\bin\cmake" -G "Visual Studio 10 2010" -D BUILD_PYSWIG_WRAPPERS:BOOL=OFF -D BUILD_LUA_WRAPPERS:BOOL=OFF -D JPEG_INCLUDE_DIR=%CD%\..\turbojpeg-win32 -D JPEG_LIBRARY=%CD%\..\turbojpeg-win32\turbojpeg-static.lib ..
C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe ALL_BUILD.vcxproj /p:Configuration=Release
if errorlevel 1 exit /B 1

rem copy down the redistributables (maybe they're on the server somewhere?)
powershell Set-ExecutionPolicy unrestricted
powershell.exe -Command (new-object System.Net.WebClient).DownloadFile('http://deepcl.hughperkins.com/Downloads/vc2010redist.zip', 'vc2010redist.zip')
if errorlevel 1 exit /B 1

"c:\program files\7-Zip\7z.exe" x vc2010redist.zip
if errorlevel 1 exit /B 1

copy vc2010redist\win32\* Release

cd Release
"c:\program files\7-Zip\7z.exe" a deepcl-win32-%version%.zip *
if errorlevel 1 exit /B 1

cd ..
echo %version%>latestUnstable.txt

