function   [obj,missinig_fields] = copy_contents(obj,other_obj,varargin)
% the main part of the copy constructor, copying the contents
% of the one class into another including opening the
% corresponding file with the same access rights
%

% leave argi unused to ignore unknown fields
[ok,mess,write_mode,argi] = parse_char_options(varargin,'-write_mode');
if ~ok
    error('HORACE:binfile_v4_common:invalid_argument',mess)
end

% fields the other object need to define to be valid
flds = obj.saveableFields();

% appropriate object
n_flds = numel(flds);
missinig_fields = {};

obj.do_check_combo_arg = false;
for i=1:n_flds
    fld = flds{i};
    try
        obj.(fld) = other_obj.(fld);
    catch ME
        missinig_fields{end+1} = fld;
    end
end
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();
%
%
facc_mode = other_obj.io_mode;
if write_mode && (strcmp(facc_mode,'rb') || (strcmp(facc_mode,'wb+')&&other_obj.data_in_file))
    obj.data_in_file_ = true;
    facc_mode = 'rb+';
end

if ~(isempty(facc_mode) && isempty(obj.full_filename))
    %
    obj.file_id_ = sqw_fopen(obj.full_filename,facc_mode);
    if isempty(obj.file_closer_)
        obj.file_closer_ = fcloser(obj.file_id_);
    end
end
