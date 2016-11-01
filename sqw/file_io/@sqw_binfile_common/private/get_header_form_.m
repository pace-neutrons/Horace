function header = get_header_form_(varargin)
% Return structure of the contributing file header in the form
% it is written on hdd.
% Usage:
% header = obj.get_header_form();
% header = obj.get_header_form('-const');
% Second option returns only the fields which do not change if
% filename or title changes
%
% Fields in file are:
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
%
% $Revision$ ($Date$)
%
persistent var_part;
persistent const_part;

if isempty(var_part)
    var_part = {'filename','','filepath',''};
end
if isempty(const_part)
    const_part = {'efix',single(1),'emode',int32(1),...
        'alatt',single([1,3]),'angdeg',single([1,3]),...
        'cu',single([1,3]),'cv',single([1,3]),...
        'psi',single(1),'omega',single(1),'dpsi',single(1),...
        'gl',single(1),'gs',single(1),...
        'en',field_var_array(1),'uoffset',single([4,1]),...
        'u_to_rlu',single([4,4]),'ulen',single([1,4]),...
        'ulabel',field_cellarray_of_strings()};
end

[ok,mess,const]=parse_char_options(varargin,{'-const'});
if ~ok
    error('SQW_BINILE_COMMON:invalid_argument',mess);
end

if const
    header = struct(const_part{:});
else
    cs = [var_part(:);const_part(:)];
    header = struct(cs{:});
end

