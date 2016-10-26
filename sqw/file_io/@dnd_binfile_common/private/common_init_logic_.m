function obj = common_init_logic_(obj,varargin)
% Initialize sqw accessor using various inputs
%
%Usage:
%>>obj=obj.init() -- initialize accessor from the object, which
%                    has been already initialized from existing
%                    sqw file and has its file opened by should_load
%                    method.
%                    should_load method should report ok, to confirm that
%                    this loader can load sqw format version provided.

%>>obj=obj.init(filename) -- initialize accessor to load  sqw file
%                    with the filename provided.
%                    The file should exist and the format of the
%                    file should correspond to this loader
%                    format.
%>>obj=obj.init(sqw_object) -- prepare accessor to save
%                    sqw object in appropriate binary format.
%                    The file name to save the data should be set
%                    separately.
%>>obj=obj.init(sqw_object,filename) -- prepare accessor to save
%                    sqw object in appropriate binary format.
%                    Also the name of the file to save the data is
%                    provided.
%                    If the filename is the name of an exisiting file,
%                    the file will be overwritten or upgraded if the loader
%                    has alreadty been initiated with this file
%
%
% $Revision$ ($Date$)
%
if nargin>1
    if ischar(varargin{1}) || isnumeric(varargin{1})
        [ok,obj,mess] = obj.should_load(varargin{1});
        if ~ok
            if ischar(varargin{1})
                fname = varargin{1};
            else
                fname = fopen(varargin{1});
            end
            error('FACCESS_SQW_COMMON:runtime_error',...
                ' Can not read input file: %s\n Reason: %s',...
                fname,mess);
        end
    else
        type = class(varargin{1});
        if ismember(type,{'d0d','d1d','d2d','d3d','d4d','sqw'})
            obj = obj.init_from_sqw_obj(varargin{:});
            return;
        else
            error('FACCESS_SQW_COMMON:runtime_error',...
                ' invalid argument, input can be only sqw/dnd object or sqw file name')
        end
    end
else % initialize opened file to read data
    if obj.file_id_ <= 0
        error('FACCESS_SQW_COMMON:runtime_error',...
            'init method: initializing sqw read operations before the input file has been opened')
    end
end
obj = obj.init_from_sqw_file();

