function opts = parse_get_sqw_args_(varargin)
% processes keywords and input options of get_sqw function.
% See get_sqw function for the description of the options
% available

if nargin > 1
    % replace single '-h' with his
    argi = cellfun(@replace_h, varargin, 'UniformOutput', false);
else
    argi = {};
end

flags = { ...
    'head', ...
    'his', ...
    'verbatim', ...
    'hverbatim', ...
    'hisverbatim', ...
    'noupgrade',...
    'norange',...
    'keep_original',...
    'nopix', ...
    'legacy', ...
    'file_backed'
    };


kwargs = struct('file_backed',false);

for flag_idx = 1:numel(flags)
    kwargs.(flags{flag_idx}) = false;
end

parser_opts = struct('prefix', '-', 'prefix_req', false);
[~, opts, ~, ~, ok, mess] = parse_arguments(argi, kwargs, flags, ...
    parser_opts);

if ~ok
    error('HORACE:faccess_sqw_v3_:invalid_argument', mess);
end

opts.verbatim = opts.verbatim || opts.hverbatim;


function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end
