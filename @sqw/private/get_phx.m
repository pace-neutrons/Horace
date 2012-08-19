function det=get_phx(filename)
% Load data from ASCII .phx file
%   >> det = get_phx(filename)
%
% data has following fields:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number - assumed to be 1:ndet
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.dphi        Row vector of angular widths (deg)
%   det.danght      Row vector of angular heights (deg)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Ibon Bustinduy: catch with Matlab routine if fortran fails

% If no input parameter given, return
if ~exist('filename','var')
    help get_phx;
    return
end

% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(filename);
det.filename=[name,ext];
det.filepath=[path,filesep];


try     %using fortran routine
  phx=get_ascii_file(filename,'phx');
catch   %using matlab routine
  disp(['Matlab loading of .phx file : ' filename]);
  phx=get_phx_matlab(filename);
end

ndet=size(phx,2);
disp([num2str(ndet) ' detector(s)']);
det.group=1:ndet;
det.phi =phx(3,:);
det.azim=phx(4,:);
det.dphi =phx(5,:);
det.danght=phx(6,:);
