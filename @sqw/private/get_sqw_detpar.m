function [det, mess] = get_sqw_detpar (fid, det_in)
% Read the detector parameter from a binary file.
%
% Syntax:
%   >> [det, mess] = get_sqw_detpar(fid, det_in)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   det_in      [optional] Data structure to which the data
%              fields below will be added or overwrite.
%
% Output:
% -------
%   det         Structure containing fields read from file (details below)
%   mess        Error message; blank if no errors, non-blank otherwise
%
% Fields read from file are:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.group       Row vector of detector group number
%   det.x2          Row vector of secondary flightpath (m)
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)
%

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if nargin==2
    if isstruct(det_in)
        det = det_in;
    else
        mess = 'Check the type of input argument det_in';
        return
    end
else
    det = [];
end

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[det.filename, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[det.filepath, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[ndet, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[det.group, count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
[det.x2,    count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
[det.phi,   count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
[det.azim,  count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
[det.width, count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
[det.height,count,ok,mess] = fread_catch(fid, [1,ndet], 'float32'); if ~all(ok); return; end;
