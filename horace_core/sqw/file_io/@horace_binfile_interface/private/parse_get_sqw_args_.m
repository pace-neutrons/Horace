function opts = parse_get_sqw_args_(varargin)
% processes keywords and input options of get_sqw function.
% See get_sqw function for the description of the options
% available

if nargin > 0
    if isstruct(varargin{1})
        argi = varargin{1};
    else
        % replace single '-h' with '-his'
        argi = cellfun(@replace_h, varargin, 'UniformOutput', false);
    end
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
    'sqw_struc',...
    'file_backed',...
    'force_pix_location'... % the key which sets to true if file_backed   
    }; %  key is explicitly present in the inputs and indicating that 
    % file_backed true/false is explicitly requested. If file_backed is 
    % not explicitly requested its value is false, but actual location of
    % the pixel data (filebacked or memory) is determined by configuration.


kwargs = struct('file_backed',false);

for flag_idx = 1:numel(flags)
    kwargs.(flags{flag_idx}) = false;
end
if isstruct(argi) % presumably structure which have been already processed
    % by other means. Assume it correct
    fn = fieldnames(argi);
    for i=1:numel(fn)
        kwargs.(fn{i}) = argi.(fn{i});
    end
    opts = kwargs;
else
    parser_opts = struct('prefix_req', false);
    [~, opts, ~, ~, ok, mess] = parse_arguments(argi, kwargs, flags, ...
        parser_opts);

    if ~ok
        error('HORACE:horace_binfile_interface:invalid_argument', mess);
    end
end
opts.verbatim = opts.verbatim || opts.hverbatim;


function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end
