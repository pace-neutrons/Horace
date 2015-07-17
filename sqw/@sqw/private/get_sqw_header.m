function [mess, header, position] = get_sqw_header (fid, nfiles)
% Read the header blocks for the contributing spe file(s) to an sqw file.
%
%   >> [mess, header, position] = get_sqw_header (fid, nfiles)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   nfiles      Number of contributing data sets to the header (>=1)
%
% Output:
% -------
%   header      Header block: scalar structure (if single spe file) or
%              cell array of structures, one per spe file. The fields are
%              listed below.
%   mess        Error message; blank if no errors, non-blank otherwise
%
%
% Fields read from file are:
% --------------------------
%   header.filename     Name of sqw file excluding path
%   header.filepath     Path to sqw file including terminating file separator
%   header.efix         Fixed energy (ei or ef depending on emode)
%   header.emode        Emode=1 direct geometry, =2 indirect geometry
%   header.alatt        Lattice parameters (Angstroms)
%   header.angdeg       Lattice angles (deg)
%   header.cu           First vector defining scattering plane (r.l.u.)
%   header.cv           Second vector defining scattering plane (r.l.u.)
%   header.psi          Orientation angle (deg)
%   header.omega        --|
%   header.dpsi           |  Crystal misorientation description (deg)
%   header.gl             |  (See notes elsewhere e.g. Tobyfit manual
%   header.gs           --|
%   header.en           Energy bin boundaries (meV) [column vector]
%   header.uoffset      Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   header.u_to_rlu     Matrix (4x4) of projection axes in hkle representation
%                        u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   header.ulen         Length of projection axes vectors in Ang^-1 or meV [row vector]
%   header.ulabel       Labels of the projection axes [1x4 cell array of character strings]
%
% The following fields two fields are part of the header, but this function just fills them with the 'empty' default:
%   header.instrument   Instrument description (scalar structure or object)
%                      Set to default value struct (1x1 structure with no fields)
%   header.sample       Sample description (scalar structure or object)
%                      Set to default value struct (1x1 structure with no fields)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if nfiles==1
    position = ftell(fid);
    [mess, header] = get_sqw_header_single (fid);
    
else
    header = cell(nfiles,1);
    position = zeros(nfiles,1);
    for i=1:nfiles
        position(i) = ftell(fid);
        [mess, header{i}] = get_sqw_header_single (fid);
        if ~isempty(mess)
            mess = [mess,': spe file ',num2str(i)];
            return
        end
    end
end


%------------------------------------------------------------------------------
function [mess, header] = get_sqw_header_single (fid)
% Read a single header structure from sqw file
%
%   >> [mess, header] = get_sqw_header_single (fid, header)
%
% Input:
% ------
%   fid             File identifier of output file
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   header          Header block: single data structure

header=struct;

try
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [header.filename, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;
    
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [header.filepath, count, ok, mess] = fread_catch(fid,[1,n],'*char'); if ~all(ok); return; end;
    
    [header.efix,   count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    [header.emode,  count, ok, mess] = fread_catch(fid,1,    'int32');   if ~all(ok); return; end;
    [header.alatt,  count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    [header.angdeg, count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    [header.cu,     count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    [header.cv,     count, ok, mess] = fread_catch(fid,[1,3],'float32'); if ~all(ok); return; end;
    [header.psi,    count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    [header.omega,  count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    [header.dpsi,   count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    [header.gl,     count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    [header.gs,     count, ok, mess] = fread_catch(fid,1,    'float32'); if ~all(ok); return; end;
    
    [ne, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    [header.en,count,ok,mess] = fread_catch(fid, [ne,1], 'float32'); if ~all(ok); return; end;
    
    [header.uoffset, count, ok, mess] = fread_catch(fid,[4,1],'float32'); if ~all(ok); return; end;
    [header.u_to_rlu,count, ok, mess] = fread_catch(fid,[4,4],'float32'); if ~all(ok); return; end;
    [header.ulen,    count, ok, mess] = fread_catch(fid,[1,4],'float32'); if ~all(ok); return; end;
    
    [n, count, ok, mess] = fread_catch(fid,2,'int32'); if ~all(ok); return; end;
    [ulabel, count, ok, mess] = fread_catch(fid,[n(1),n(2)],'*char'); if ~all(ok); return; end;
    header.ulabel=cellstr(ulabel)';
    
    header.instrument = struct;
    header.sample = struct;
    
catch
    mess='Error reading header block from file';
end
