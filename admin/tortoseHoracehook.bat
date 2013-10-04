@echo off
set SCRDIR=%CD%
rem pause
"%MATLABDIR%64\sys\perl\win32\bin\perl.exe" "%SCRDIR%\svn_matlab_commit_hook.pl" "%SCRDIR%\horace_version.m"
rem pause
exit 0;