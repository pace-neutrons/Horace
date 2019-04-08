function detpar_form = get_detpar_form_(varargin)
% Return structure of the contributing file header in the form
% it is written on hdd.
% Usage:
% header = obj.get_detpar_form();
% header = obj.get_detpar_form('-const');
%
% Second option returns only the fields which do not change if
% filename or title changes
%
%
% Fields in the structure are:
%
% --------------------------
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
% one field of the file 'ndet' is written to the file but not
% present in the structure, so has format: field_not_in_structure
% group,x2,phi,azim,width and height array sizes are defined by
% this structure size
%
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
%
persistent var_part;
persistent const_part;
%
if isempty(var_part)
    var_part = {'filename','','filepath',''};
end
if isempty(const_part)
    const_part = { 'ndet',field_not_in_structure('group'),...
        'group',field_const_array_dependent('ndet'),...
        'x2',field_const_array_dependent('ndet'),...
        'phi',field_const_array_dependent('ndet'),...
        'azim',field_const_array_dependent('ndet'),...
        'width',field_const_array_dependent('ndet'),...
        'height',field_const_array_dependent('ndet')};
end
%
[ok,mess,const]=parse_char_options(varargin,{'-const'});
if ~ok
    error('SQW_BINILE_COMMON:invalid_argument',mess);
end

if const
    detpar_form = struct(const_part{:});
else
    cs = [var_part(:);const_part(:)];
    detpar_form = struct(cs{:});
end

