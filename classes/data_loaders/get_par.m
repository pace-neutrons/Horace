function par = get_par(file_name,varargin)
% Function uses loaders factory to read ASCII par data form correspondent file
%
%Usage:
%>>par=get_par(file_name,[-nohor])
%
%Parameters:
%file_name   -- the name of the file, which contains par data nxspe or par
%-nohor      -- optional key, which request returned par data as (6xn_detectors) array
%               otherwise, data are returmed as horace
%               structure
%
% the Horace structure has a form:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number
%   det.x2          Secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)
%
%   (6,ndet) array has fields:
%
%     1st column    sample-detector distance
%     2nd  "        scattering angle (deg)
%     3rd  "        azimuthal angle (deg)
%                   (west bank = 0 deg, north bank = -90 deg etc.)
%                   (Note the reversed sign convention cf .phx files)
%     4th  "        width (m)
%     5th  "        height (m)
%     6th  "        detector ID
%
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)
%
% redefine the file name of the par file
if ~exist('file_name','var')
    error('GET_PAR:invalid_argument','function has to be called with valid filename');
end

[ok,mess,full_file_name]=check_file_exist(file_name,{'.par','.phx'});
if ok
    % create ascii loader object
    rd = asciipar_loader(full_file_name);
else     % it should be an hdf file with par data in it
    rd = loaders_factory.instance().get_loader(file_name);
end

% return loaded par data from specified loader instance
par=rd.load_par(varargin{:});
