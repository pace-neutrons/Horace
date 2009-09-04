function det=get_par(filename)
% Load data from ASCII Tobyfit .par file
%   >> det = get_par(filename)
%
% data has following fields:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.x2          Secondary flightpath (m)
%   det.group       Row vector of detector group number - assumed to be 1:ndet
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Ibon Bustinduy: catch with Matlab routine if fortran fails

% If no input parameter given, return
if ~exist('filename','var')
    help get_par;
    return
end

% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% Get file name and path (incl. final separator)
[path,name,ext,ver]=fileparts(filename);
det.filename=[name,ext,ver];
det.filepath=[path,filesep];

% Read par file
try     %using fortran routine
    par=get_par_fortran(filename);
catch   %using matlab routine
    disp(['Can not invoke fortran .par loading, using Matlab; file: ' filename]);
    par=get_par_matlab(filename);
end

ndet=size(par,2);
disp([num2str(ndet) ' detector(s)']);
det.group=1:ndet;
det.x2=par(1,:);
det.phi=par(2,:);
det.azim=-par(3,:); % Note sign change to get correct convention
det.width=par(4,:);
det.height=par(5,:);
