echo on
% -------------------------------------------------------------------
% Script to demostate how it works on mac.
% -------------------------------------------------------------------

addpath(genpath('/Volumes/ISIS_HD/Subversion/Horace/branches/sqw_libisis'));
horace('/Volumes/ISIS_HD/Subversion/Libisis/trunk/');

% -------------------------------------------------------------------
% Read sqw data from "/Volumes/ISIS_HD/fe/w110.sqw"
% -------------------------------------------------------------------
w1=read_sqw('/Volumes/ISIS_HD/fe/w110.sqw'); % w1 will be an d2d object

echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on

% -------------------------------------------------------------------
% We could try to convert it to an IXTdataset_2d object ->
% -------------------------------------------------------------------

w_1=convert_to_libisis(w1); % w_1 will be an IXTdataset_2d object
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on 

% -------------------------------------------------------------------
% Read raw data from "MAP10241.RAW"
% -------------------------------------------------------------------

rawfile1=IXTraw_file('/Volumes/ISIS_HD/Subversion/Libisis/trunk/tests/maps_files/MAP10241.RAW')
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on

% -------------------------------------------------------------------
% Get spectra
% -------------------------------------------------------------------

w2=getspectra(rawfile1, [1:50]); % w2 will be an IXTdataset_2d object
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on

% -------------------------------------------------------------------
% w2 can use all functions ...
% -------------------------------------------------------------------

da(w2)
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on
dl(w2)
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on
de(w2)
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on


% -------------------------------------------------------------------
% HOWEVER w1 can only use 'dl' and 'ds' functions ...
% -------------------------------------------------------------------

da(w1)
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on

ds(w1)
echo off 
disp('');
reply = input('...Press any key to continue. ', 's');
echo on
    
% -------------------------------------------------------------------
% IF we try to use 'dl' or 'mp' functions over w1 or even w_1 it will crash
% and exit from MATLAB !
% -------------------------------------------------------------------
echo off 
disp('');
reply = input('After this Matlab will crash... Press any key to continue. OR [S] to stop it now.', 's');
if (reply=='S')|(reply=='s'),
    disp('PLEASE, notice aspect of title, x and y labels...');
else
    dl(w_1)
end
echo on



echo off