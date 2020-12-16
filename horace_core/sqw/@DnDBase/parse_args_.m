function args = parse_args_(obj, varargin)
% Parse the argument passed to the DnD constructor.
%
% Return struct with the data set to the appropriate element:
% - args.filename  % string, presumed to be filename
% - args.dnd_obj   % DnD class instance
% - args.sqw_obj   % SQW class instance
% - args.data_struct % generic struct, presumed to represent DnD

parser = inputParser();
parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
parser.KeepUnmatched = true;
parser.parse(varargin{:});

input = parser.Results.input;
args = struct('dnd_obj', [], 'sqw_obj', [], 'filename', [], 'data_struct', []);

if isa(input, 'SQWDnDBase')
    if isa(input, class(obj))
        args.dnd_obj = input;
    elseif isa(input, 'sqw')
        args.sqw_obj = input;
    else
        error([upper(class(obj)), ':' class(obj)], ...
            [upper(class(obj)) ' cannot be constructed from an instance of this object "' class(input) '"']);
    end
elseif is_string(input)
    args.filename = input;
elseif isstruct(input) && ~isempty(input)
    args.data_struct = input;
else
    % create struct holding default instance
    args.data_struct = data_sqw_dnd(obj.NUM_DIMS);
end
end
