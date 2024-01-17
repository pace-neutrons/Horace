function obj = init(obj,varargin)
% the content of the non-empty constructor, also used to
% initialize empty instance of the object
%
% here we go through the various options for what can
% initialise an sqw object
arg_struc = sqw.parse_sqw_args(varargin{:});

% i) copy - it is an sqw
if ~isempty(arg_struc.sqw_obj)
    obj = copy(arg_struc.sqw_obj);
    % ii) filename - init from a file or file accessor
elseif ~isempty(arg_struc.file)
    obj.loading = true;
    obj = obj.init_from_file(arg_struc);
    % iii) struct a struct, pass to the struct
    % loader
    obj.loading = false;
elseif ~isempty(arg_struc.data_struct)
    obj.loading = true;
    if isfield(arg_struc.data_struct,'data')
        if isfield(arg_struc.data_struct.data,'version')
            obj = serializable.from_struct(arg_struc.data_struct);
        else
            obj = from_bare_struct(obj,arg_struc.data_struct);
        end
    else
        error('HORACE:sqw:invalid_argument',...
            'Unidentified input data structure %s', ...
            disp2str(arg_struc.data_struct));
    end
    obj.loading = false;
end
