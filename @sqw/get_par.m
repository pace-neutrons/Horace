function det=get_par(this,filename,varargin)
% Load data from ASCII Tobyfit .par file and returns data in the form, requested by horace
%Usage:
%>> det = get_par(sqw,filename)
%>> det = get_par(sqw,filename,'-array')
%  if varargin ('-array' switch is) present, do not convert into detector structure but return
%  initial array, which is 6xNDet array with NDet equal to number of detectors and the column 
%  meaning correspond to the 

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
%

% Original author: T.G.Perring
%
% $Revision: 601 $ ($Date: 2012-02-08 14:46:10 +0000 (Wed, 08 Feb 2012) $)
%
% If no input parameter given, return
if ~exist('filename','var')
    help get_par;
    return
end
if ~exist(filename,'file')
    error('GET_PAR:invalid_argument',[' file: ',filename,' does not exist']);
end
det = load_par(this,filename,varargin{:});
