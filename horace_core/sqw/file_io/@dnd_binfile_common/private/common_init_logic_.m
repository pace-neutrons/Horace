function obj = common_init_logic_(obj,varargin)
% Initialize sqw accessors using various inputs
%
%Usage:
%>>obj=obj.init(init_obj) -- initialize accessors using obj_init
% class, containing appropriate initialization information
%                    already retrieved from existing
%                    sqw file and has its file opened by should_load
%                    method.
%                    should_load method should report ok, to confirm that
%                    this loader can load sqw format version provided.

%>>obj=obj.init(filename) -- initialize accessors to load  sqw file
%                    with the filename provided.
%                    The file should exist and the format of the
%                    file should correspond to this loader
%                    format.
%>>obj=obj.init(sqw_object) -- prepare accessors to save
%                    sqw object in appropriate binary format.
%                    The file name to save the data should be set
%                    separately.
%>>obj=obj.init(sqw_object,filename) -- prepare accessors to save
%                    sqw object in appropriate binary format.
%                    Also the name of the file to save the data is
%                    provided.
%                    If the filename is the name of an existing file,
%                    the file will be overwritten or upgraded if the loader
%                    has already been initiated with this file
%
% obj = obj.init(save_struct) % initialize the class using the structure
%                   obtained using saveobj method.
%
%>>obj=obj.init(another_object) -- copy constructor. Also accepts all
%                 additional arguments from above.
%
%

%
if nargin<1
    error('SQW_FILE_IO:invalid_argument',...
        'dnd_binfile_common::init method invoked without any input argument')
end
%
if isa(varargin{1},'dnd_binfile_common') % run copy constructor
    obj = obj.copy_contents(varargin{1});
    argi = varargin(2:end);
else
    argi = varargin;
end
%
if isempty(obj.sqw_serializer_)
    obj.sqw_serializer_ = sqw_serializer();
end
%
if isempty(argi)
    return;
end
input = argi{1};
argi = argi(2:end);
%
if isa(input,'obj_init')
    if input.file_id<0
        error('SQW_FILE_IO:invalid_argument',...
            'dnd_binfile_common::init method: get incorrect initialization information')
    end
    obj = obj.init_by_input_file(input);
elseif ischar(input) || isnumeric(input)
    [ok,objinit,mess] = obj.should_load(input);
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
elseif isstruct(input) && isfield(input,'class_name')
    obj = loadobj(input);
else
    type = class(input);
    if ismember(type,{'d0d_old','d1d_old','d2d_old','d3d_old','d4d_old','sqw_old','sqw'}) || is_sqw_struct(input)
        % still needed check against an obj already defined and new object
        % used as upgrade
        if ~ischar(obj.num_dim) && obj.file_id_ > 0
            error('SQW_FILE_IO:runtime_error',...
                'Upgrade of existing object with new sqw/dnd object is not yet implemented')
        end
        obj = obj.init_from_sqw_obj(input);
        if nargin == 3
            obj = obj.set_file_to_update(argi{:});
        else
            if ~isempty(obj.filename)
                obj = obj.set_file_to_update();
            end
        end
        return;
    else
        error('SQW_FILE_IO:invalid_argument',...
            'dnd_binfile_common::init method: input can be only sqw/dnd object or sqw file name')
    end
end
obj = obj.init_from_sqw_file(argi{:});

