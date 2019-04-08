function data_str = get_se_npix_data_(obj,varargin)
% Read signal, error and npix information and return them as the fields
% of sqw data structure:
%
% Usage:
%>>data_struct = obj.get_se_npix_data_();
%>>data_struct = obj.get_se_npix_data_(data_struct);
%
% Where the first form creates structure with fields s,e,npix, containing
% signal, error and npix information correspondingly read from hdd
% and the second form appends or replaces these fields in the
% structure provided as input.
%
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
%
if isempty(varargin)
    data_str = struct();
else
    data_str = varargin{1};
end
fseek(obj.file_id_,obj.s_pos_,'bof');
check_error_report_fail_(obj,...
    'DND_BINFILE_COMMON::get_data: Can not move to the signal start position');

numl = prod(obj.dnd_dimensions);
if obj.convert_to_double
    data_str.s    = fread(obj.file_id_,numl,'float32');
    data_str.e    = fread(obj.file_id_,numl,'float32');
    data_str.npix = fread(obj.file_id_,numl,'uint64');
else
    data_str.s    = fread(obj.file_id_,numl,'*float32');
    data_str.e    = fread(obj.file_id_,numl,'*float32');
    data_str.npix = fread(obj.file_id_,numl,'*uint64');
end
check_error_report_fail_(obj,...
    'get_data: Can not read signal error or npix array');

if obj.num_dim>1
    data_str.s = reshape(data_str.s,obj.dnd_dimensions);
    data_str.e = reshape(data_str.e,obj.dnd_dimensions);
    data_str.npix = reshape(data_str.npix,obj.dnd_dimensions);
end
