@echo off
set SCRDIR=%CD%
rem pause
%MATLABDIR%\sys\perl\win32\bin\perl.exe %SCRDIR%\..\Libisis_Dev\Libisis\ISIS_utilities\svn_matlab_commit_hook.pl %SCRDIR%\utilities\horace_version.m
exit 0;