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
%      The file name to save the data should be provided separately.
%
%>>obj=obj.init(sqw_object,filename) - prepare accessor to save
%      sqw object in appropriate binary format.
%      Also the name of the file to save the data is provided.
%      If the filename is the name of an existing file,
%      the file will be overwritten or upgraded if the loader
%      has already been initiated with this file.
%
%
if isempty(varargin)
    return;
end
%
if isa(varargin{1},'horace_binfile_interface') % run copy constructor
    obj = obj.copy_contents(varargin{1});
    argi = varargin(2:end);
else
    argi = varargin;
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
        error('HORACE:horace_binfile_interface:invalid_argument',...
            'Incorrect initialization information from obj_init class. Input file is not opened')
    end
    obj = obj.init_input_stream(input);
elseif ischar(input) || isnumeric(input)
    [ok,objinit,mess] = obj.should_load(input);
    if ischar(input)
        fname = input;
    else
        fname = fopen(input);
    end
    if ok
        obj.full_filename = fname;
    else
        error('HORACE:horace_binfile_interface:runtime_error',...
            'Can initialize loader by input file: %s\n Reason: %s',...
            fname,mess);
    end
    obj = obj.init_input_stream(objinit);
elseif isstruct(input) && (isfield(input,'class_name') || isfield(input,'serial_name'))
    obj = loadobj(input);
    return;
else
    if isa(input, 'SQWDnDBase') || is_sqw_struct(input)
        % still needed check against an obj already defined and new object
        % used as upgrade
        if ~ischar(obj.num_dim) && obj.file_id_ > 0
            error('HORACE:binfile_v2_common:runtime_error',...
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
        error('HORACE:binfile_v2_common:invalid_argument',...
            'Input can be only sqw/dnd object or sqw file name.\n In fact, its class is: %s and value: %s', ...
            class(input),disp2str(input));
    end
end
obj = obj.init_from_sqw_file(argi{:});

