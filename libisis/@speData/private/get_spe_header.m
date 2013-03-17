function [ndet,en]=get_spe_header(filename)
% Load header information from ASCII .spe file
%
%   >> [ndet,en]=get_spe_header(filename)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Read start of spe file using matlab (not likely to be too large, so OK)
fid=fopen(filename,'rt');
nsize = str2num(fgets(fid));    % number of detector groups and energy bins
ndet = nsize(1);
ne = nsize(2);
tmp = fgets(fid);   % read ### Phi grid
phi = fscanf(fid,'%10f',ndet+1);    % dummy detector angles - are rubbish
tmp = fgetl(fid);   % read end-of-line
tmp = fgets(fid);   % read ### Energy grid
en=fscanf(fid,'%10f',ne+1);    % energy bin boundaries
fclose(fid);
