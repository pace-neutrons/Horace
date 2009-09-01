function [S,ERR,en] = get_spe_matlab(filename)
% Get signal, error and energy bin boundaries for spe file
%
%   >> [S,ERR,en] = get_spe_matlab(filename)
%
%   S          [ne x ndet] array of signal values
%   ERR        [ne x ndet] array of error values (st. dev.)
%   en         Column vector of energy bin boundaries

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)
%
% Based on Radu coldea routine load_spe in mslice

fid=fopen(filename,'rt');
if fid==-1,
   error(['Error opening file ',filename]);
end

% Read number of detectors and energy bins
ndet=fscanf(fid,'%d',1);
ne=fscanf(fid,'%d',1);
temp=fgetl(fid);    % read eol
temp=fgetl(fid);    % read string '### Phi Grid'
temp=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
temp=fgetl(fid);    % read eol character of the Phi grid table
temp=fgetl(fid);    % read string '### Energy Grid'
en=fscanf(fid,'%10f',ne+1); % read energy grid

% Read data
S=zeros(ne,ndet);
ERR=zeros(ne,ndet);
for i=1:ndet,
    temp=fgetl(fid);        % read eol character
    temp=fgetl(fid);        % get rid of line ### S(Phi,w)
    S(:,i)=fscanf(fid,'%10f',ne);
    temp=fgetl(fid);        % read eol character
    temp=fgetl(fid);        % get rid of line ### Errors
    ERR(:,i)=fscanf(fid,'%10f',ne);
end
fclose(fid);
