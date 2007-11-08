function det=load_phx(filename)
% Load data from ASCII .phx file
%   >> det = load_phx(filename)
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

% T.G.Perring   13/6/07
% I. Bustinduy  27/8/07
% If no input parameter given, return
if ~exist('filename','var')
    help load_phx;
    return
end

% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% Get file name and path (incl. final separator)
[path,name,ext,ver]=fileparts(filename);
det.filename=[name,ext,ver];
det.filepath=[path,filesep];


try %using fortran routine
  % Read spe file using fortran routine
  disp(['Fortran loading of .phx file : ' filename]);
  phx=load_phx_fortran(filename);
catch%using matlab routine
  % Read spe file using Matlab routine
  disp(['Matlab loading of .phx file : ' filename]);
  phx=load_phx_matlab(filename);
end
disp([num2str(ndet) ' detector(s)']);

ndet=size(phx,2);
det.group=1:ndet;
det.phi =phx(3,:);
det.azim=phx(4,:);
det.dphi =phx(5,:);
det.danght=phx(6,:);
