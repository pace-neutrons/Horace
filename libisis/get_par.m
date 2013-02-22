function det=get_par(filename,varargin)
% Load data from ASCII Tobyfit .par file
%>>det = get_par(filename)
%>>det = get_par(filename,'-hor')
%
% It is a proxy to public get_par sqw method
%
% if the second form is used, the data has following fields:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number - assumed to be 1:ndet
%   det.x2          Secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)
%
%if the first form is used, data not converted into detector structure but
%returned as an array of 6xNdet elements.
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
if ismember('-hor',varargin)
    det = get_par(sqw(),filename);    
else
    det = get_par(sqw(),filename,'-array');    
end
