function [data, mess] = get_sqw_header (fid)
% Read the header block for the results of performing calculate projections on spe file(s).
%
%   >> [data, mess] = get_sqw_header(fid, data_in)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%
% Output:
% -------
%   data        Structure containing fields read from file (details below)
%   mess        Error message; blank if no errors, non-blank otherwise
%
%
% Fields read from file are:
%   data.filename   Name of sqw file excluding path
%   data.filepath   Path to sqw file including terminating file separator
%   data.efix       Fixed energy (ei or ef depending on emode)
%   data.emode      Emode=1 direct geometry, =2 indirect geometry
%   data.alatt      Lattice parameters (Angstroms)
%   data.angdeg     Lattice angles (deg)
%   data.cu         First vector defining scattering plane (r.l.u.)
%   data.cv         Second vector defining scattering plane (r.l.u.)
%   data.psi        Orientation angle (deg)
%   data.omega      --|
%   data.dpsi         |  Crystal misorientation description (deg)
%   data.gl           |  (See notes elsewhere e.g. Tobyfit manual
%   data.gs         --|
%   data.en         Energy bin boundaries (meV) [column vector]
%   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
%   data.instrument Instrument description (scalar structure or object)
%                   Set to default value struct (1x1 structure with no fields)
%   data.sample     Sample description (scalar structure or object)
%                   Set to default value struct (1x1 structure with no fields)
%
% The instrument and sample fields will be read by get_sqw_header_opt, if the optional
% block is present in the sqw file.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


data = [];

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[data.filename, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[data.filepath, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;

[data.efix,   count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
[data.emode,  count, ok, mess] = fread_catch(fid,1,    'int32');   if ~all(ok); return; end;
[data.alatt,  count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
[data.angdeg, count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
[data.cu,     count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
[data.cv,     count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
[data.psi,    count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
[data.omega,  count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
[data.dpsi,   count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
[data.gl,     count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
[data.gs,     count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;

[ne, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
[data.en,count,ok,mess] = fread_catch(fid, [ne,1], 'float32'); if ~all(ok); return; end;

[data.uoffset, count, ok, mess] = fread_catch(fid,[4,1],'float32'); if ~all(ok); return; end;
[data.u_to_rlu,count, ok, mess] = fread_catch(fid,[4,4],'float32'); if ~all(ok); return; end;
[data.ulen,    count, ok, mess] = fread_catch(fid,[1,4],'float32'); if ~all(ok); return; end;

[n, count, ok, mess] = fread_catch(fid,2,'int32'); if ~all(ok); return; end;
[ulabel, count, ok, mess] = fread_catch(fid,[n(1),n(2)],'*char'); if ~all(ok); return; end;
data.ulabel=cellstr(ulabel)';

data.instrument = struct;
data.sample = struct;
