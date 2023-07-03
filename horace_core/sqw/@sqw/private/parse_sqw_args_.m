function args = parse_sqw_args_(~,varargin)
% Parse a single argument passed to the SQW constructor
%
% Return struct with the data set to the appropriate element:
% args.filename  % string, presumed to be filename
% args.sqw_obj   % SQW class instance
% args.data_struct % generic struct, presumed to represent SQW
% args.pixel_page_size % size of PixelData page in bytes

parser = inputParser();
parser.KeepUnmatched = true;  % ignore unmatched parameters
parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || ...
    is_string(x) || ...
    isa(x,'horace_binfile_interface') || ...
    isstruct(x)));
parser.addParameter('file_backed', false, @islognumscalar)
parser.parse(varargin{:});
if ~isempty(fieldnames(parser.Unmatched))
    error('HORACE:sqw:invalid_argument', ...
        'Unrecognized init parameter: %s', ...
        disp2str(parser.Unmatched));
end

input = parser.Results.input;
args = struct('sqw_obj', [], 'filename', [], 'data_struct', [], ...
    'file_backed', parser.Results.file_backed);
if isempty(parser.UsingDefaults)
    args.force_filebacked_selection = true;
else
    args.force_filebacked_selection = false;
end

if isa(input, 'SQWDnDBase')
    if isa(input, 'DnDBase')
        args.data_struct = struct('data',input);
    else
        args.sqw_obj = input;
    end
elseif is_string(parser.Results.input)
    args.filename = input;
elseif (isstruct(input)||isa(input,'horace_binfile_interface')) && ~isempty(input)
    args.data_struct = input;
else
    % create struct holding default instance
    args.data_struct = make_sqw(0);
end
