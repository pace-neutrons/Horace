function  obj=init_from_sqw_file(obj,varargin)
%init_from_sqw_file -- initialize file reader/writer from binary data file
%

obj = obj.check_obj_initated_properly();

% Read block allocation table from opened file id.
obj.bat_ = obj.bat_.get_bat(obj.file_id_);
%