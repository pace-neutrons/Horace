rem @echo off
rem set SCRDIR= %CD%

set SCRDIR=c:\Users\wkc26243\Documents\work\Horace\admin
set MATLABDIR=c:\programming\Matlab2012a
copy /b "%SCRDIR%\horace_version.m"+,,
rem pause
rem the path to matlab assumed to be defined as "some_path"32 or "some_path"64 where number identifies appropriate matlab version (32 or 64 bit)
rem the same convention is used in visual studio projects which build 32 or 64-bit versions of mex files. 
rem "%MATLABDIR%32\sys\perl\win32\bin\perl.exe" "%SCRDIR%\svn_matlab_commit_hook.pl" "%SCRDIR%\horace_version.m"
pause
exit 0;