@echo off
set SCRDIR=%CD%
rem pause
"%MATLABDIR%\sys\perl\win32\bin\perl.exe" "%SCRDIR%\svn_matlab_commit_hook.pl" "%SCRDIR%\horace_version.m"
exit 0;