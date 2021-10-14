function args = parse_args_(obj, varargin)
% Parse the argument passed to the DnD constructor.
%
% Return struct with the data set to the appropriate element:
% - args.filename  % string, presumed to be filename
% - args.dnd_obj   % DnD class instance
% - args.sqw_obj   % SQW class instance
% - args.data_struct % generic struct, presumed to represent DnD


if ~isempty(varargin) && isvector(varargin{1}) && isnumeric(varargin{1})
    % attempting to parse the numeric projection form of the input always
    % seems to cause the parser to think a parameter is involved, so
    % detecting this separately and passing it to the processing  function
    % whole, to produce a data_sqw_dnd
    input_data = varargin;
    
    input_data = data_sqw_dnd(input_data{:});
else
    parser = inputParser();
    
    parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase')   || ... %sqw/dnd
        isa(x, 'data_sqw_dnd') || ... % data_sqw_dnd
        is_string(x)           || ... % filename
        isstruct(x)));                % struct of data_sqw_dnd type
    parser.KeepUnmatched = true;
    parser.parse(varargin{:});
    
    input_data = parser.Results.input;
end
if is_string(input_data)
    array_numel = 1;
    array_size  = [1,1];
else
    array_numel = numel(input_data);
    array_size  = size(input_data) ;
end

args = struct(...
    'array_numel',array_numel , ...
    'array_size',   array_size, ...
    'dnd_obj',              [], ...
    'sqw_obj',              [], ...
    'filename',             [], ...
    'data_struct',          [], ...
    'data_sqw_dnd',         []);


if isa(input_data, 'SQWDnDBase')
    if isa(input_data, class(obj))
        args.dnd_obj = input_data;
        
    elseif isa(input_data, 'sqw')
        args.sqw_obj = input_data;
    else
        error([upper(class(obj)), ':' class(obj)], ...
            [upper(class(obj)) ' cannot be constructed from an instance of this object "' class(input_data) '"']);
    end
elseif isa(input_data, 'data_sqw_dnd')
    args.data_sqw_dnd = input_data;
elseif is_string(input_data)
    args.filename = {input_data};
elseif isstruct(input_data) && ~isempty(input_data)
    args.data_struct = input_data;
else
    % create struct holding default instance
    args.data_struct = data_sqw_dnd(obj.NUM_DIMS);
end

end
