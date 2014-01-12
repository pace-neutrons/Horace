@echo off
set SCRDIR=%CD%
rem pause
rem the path to matlab assumed to be defined as "some_path"32 or "some_path"64 where number identifies appropriate matlab version (32 or 64 bit)
rem the same convention is used in visual studio projects which build 32 or 64-bit versions of mex files. 
"%MATLABDIR%32\sys\perl\win32\bin\perl.exe" "%SCRDIR%\svn_matlab_commit_hook.pl" "%SCRDIR%\herbert_version.m"
rem pause
exit 0;