function obj = init(obj,varargin)
% Initialize sqw accessor using various input sources
%
%Usage:
%>>obj=obj.init(init_obj) - initialize accessor using obj_init
%      class, containing appropriate initialization information
%      already retrieved from existing sqw file and has its file
%      opened by should_load  method.
%      should_load method should report ok, to confirm that
%      this loader can load sqw format version provided.
%
%>>obj=obj.init(filename) - initialize accessor to load
%      sqw file with the filename provided.
%      The file should exist and the format of the
%      file should correspond to this loader  format.
%
%>>obj=obj.init(sqw_object) - prepare accessor to save
%      sqw object in appropriate binary format.
%      The file name to save the data should be set separately.
%
%>>obj=obj.init(sqw_object,filename) - prepare accessor to save
%      sqw object in appropriate binary format.
%      Also the name of the file to save the data is provided.
%      If the filename is the name of an existing file,
%      the file will be overwritten or upgraded if the loader
%      has already been initiated with this file.
%
if nargout<1
    error('SQW_FILE_IO:invalid_argument',...
        'dnd_binfile_common::init needs to have one output argument')
end

obj = common_init_logic_(obj,varargin{:});

