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
parser.addParameter('pixel_page_size', PixelData.DEFAULT_PAGE_SIZE, ...
    @PixelData.validate_mem_alloc);
parser.parse(varargin{:});

input = parser.Results.input;
args = struct('sqw_obj', [], 'filename', [], 'data_struct', [], 'pixel_page_size', []);

args.pixel_page_size = parser.Results.pixel_page_size;

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

