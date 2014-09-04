function [mess, header] = get_sqw_header (fid, fmt_ver, nfiles)
% Read the header blocks for the contributing spe file(s) to an sqw file.
%
%   >> [mess, header] = get_sqw_header (fid, fmt_ver, nfiles)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
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
    pos_arr = ftell(fid);
    [mess, header] = get_sqw_header_single (fid,fmt_ver);
    
else
    header = cell(nfiles,1);
    for i=1:nfiles
        [mess, header{i}] = get_sqw_header_single (fid,fmt_ver);
        if ~isempty(mess)
            mess = [mess,': spe file ',num2str(i)];
            return
        end
    end
end


%------------------------------------------------------------------------------
function [mess, header] = get_sqw_header_single (fid, fmt_ver)
% Read a single header structure from sqw file
%
%   >> [mess, header] = get_sqw_header_single (fid, header)
%
% Input:
% ------
%   fid             File identifier of output file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   header          Header block: single data structure

mess='';

[fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver);

try
    % Read from file
    header.filename = read_sqw_var_char (fid, fmt_ver);
    header.filepath = read_sqw_var_char (fid, fmt_ver);

    header.efix   = fread(fid, 1, fmt_dble);
    header.emode  = fread(fid, 1, fmt_int);
    header.alatt  = fread(fid, [1,3], fmt_dble);
    header.angdeg = fread(fid, [1,3], fmt_dble);
    header.cu     = fread(fid, [1,3], fmt_dble);
    header.cv     = fread(fid, [1,3], fmt_dble);
    header.psi    = fread(fid, 1, fmt_dble);
    header.omega  = fread(fid, 1, fmt_dble);
    header.dpsi   = fread(fid, 1, fmt_dble);
    header.gl     = fread(fid, 1, fmt_dble);
    header.gs     = fread(fid, 1, fmt_dble);
    
    ne = fread(fid, 1, fmt_int);
    header.en = fread(fid, [ne,1], fmt_dble);

    header.uoffset  = fread(fid, [4,1], fmt_dble);
    header.u_to_rlu = fread(fid, [4,4], fmt_dble);
    header.ulen     = fread(fid, [1,4], fmt_dble);
    
    header.ulabel=read_sqw_var_char (fid,fmt_ver,true)';
    
    % Structures with no fields for sample and instrument
    header.instrument = struct;
    header.sample = struct;
    
catch
    mess='Error reading header block from file';
    header=struct([]);

end
