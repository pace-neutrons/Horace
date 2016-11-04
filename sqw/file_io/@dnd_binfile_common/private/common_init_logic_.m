function obj = common_init_logic_(obj,varargin)
% Initialize sqw accessor using various inputs
%
%Usage:
%>>obj=obj.init(init_obj) -- initialize accessor using obj_init
% class, containing appropriate initialization information
%                    already retrieved from existing
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

if isempty(obj.sqw_serializer_)
    obj.sqw_serializer_ = sqw_serializer();
end
if nargin<1
    error('SQW_FILE_IO:invalid_argument',...
        'dnd_binfile_common::init method invoked without any input argument')
end

input = varargin{1};

if isa(input,'obj_init')
    if input.file_id<0
        error('SQW_FILE_IO:invalid_argument',...
            'dnd_binfile_common::init method: get incorrect initialization information')
    end
    obj = obj.init_by_input_file(input);
elseif ischar(input) || isnumeric(input)
    [ok,objinit,mess] = obj.should_load(varargin{1});
    if ~ok
        if ischar(input)
            fname = input;
        else
            fname = fopen(input);
        end
        error('SQW_FILE_IO:runtime_error',...
            'dnd_binfile_common::init method: Can not read input file: %s\n Reason: %s',...
            fname,mess);
    end
    obj = obj.init_by_input_file(objinit);
else
    type = class(input);
    if ismember(type,{'d0d','d1d','d2d','d3d','d4d','sqw'})
        % still needed check against an obj already defined and new object
        % used as upgrade
        if ~ischar(obj.num_dim) && obj.file_id_ > 0
            error('SQW_FILE_IO:runtime_error',...
                'Upgrade existing object with new sqw/dnd object is not yet implemented')
        end
        obj = obj.init_from_sqw_obj(varargin{:});
        if nargin == 3
            obj = obj.set_file_to_write(varargin{2});
        else
            if ~isempty(obj.filename)
                obj = obj.set_file_to_write();
            end
        end
        return;
    else
        error('SQW_FILE_IO:invalid_argument',...
            'dnd_binfile_common::init method: input can be only sqw/dnd object or sqw file name')
    end
end
obj = obj.init_from_sqw_file();
