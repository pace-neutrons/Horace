function  obj=init_from_sqw_file(obj,varargin)
%init_from_sqw_file -- initialize file reader/writer from binary data file
% 
% 
[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:binfile_v4_common:invalid_argument',mess);
end
if ~isempty(argi)
    update = true;
    obj.full_filename= argi{1};
end

if update
    obj = obj.check_obj_initated_properly();
end

% Read block allocation table from opened file id.
obj.bat_ = obj.bat_.get_bat(obj.file_id_);
%
if isempty(obj.full_filename)
    obj.full_filename = fopen(obj.file_id_);
end
obj.data_in_file_ = true;