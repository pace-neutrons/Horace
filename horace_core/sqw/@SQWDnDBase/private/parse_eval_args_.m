function [func_handle, pars, opts] = parse_eval_args_(win, func_handle, pars, varargin)
%PARSE_EVAL_ARGS -- parser function used by sqw_eval and sqw_op algorithms
%to process their input parameters which fine-tune the calculation
%parameters.
%
thePageOp = [];
if numel(varargin)> 0 && isa(varargin{1},'PageOp_sqw_eval')
    thePageOp = varargin{1};
    argi= varargin(2:end);
else
    argi = varargin;
end

flags = {'-all', '-average', '-filebacked','-nopix','-test_input_parsing'};
[~, ~, all_flag, ave_flag, filebacked_flag,nopix_flag,test_inputs, args] =...
    parse_char_options(argi, flags);

parser = inputParser();
parser.addRequired('func_handle', @(x) isa(x, 'function_handle'));
parser.addRequired('pars');
parser.addParameter('average', ave_flag, @islognumscalar);
parser.addParameter('all', all_flag, @islognumscalar);
parser.addParameter('filebacked', filebacked_flag, @islognumscalar);
parser.addParameter('nopix', nopix_flag, @islognumscalar);
parser.addParameter('test_input_parsing', test_inputs, @islognumscalar);
parser.addParameter('outfile', {}, @(x) iscellstr(x) || istext(x));

parser.parse(func_handle, pars, args{:});
opts = parser.Results;
% compartibility with various input algorithms
opts.all_bins = opts.all;
opts.pageop_processor = thePageOp;

if ~iscell(opts.pars)
    opts.pars = {opts.pars};
end
if ~iscell(opts.outfile)
    opts.outfile = {opts.outfile};
end

outfiles_empty = all(cellfun(@(x) isempty(x), opts.outfile));
if ~outfiles_empty && (numel(win) ~= numel(opts.outfile))
    error( ...
        'HORACE:sqw:invalid_argument', ...
        ['Number of outfiles specified must match number of input objects.\n' ...
        'Found %i outfile(s), but %i sqw object(s).'], ...
        numel(opts.outfile), numel(win) ...
        );
end
if outfiles_empty
    if opts.filebacked
        opts.outfile = gen_unique_file_paths( ...
            numel(win), 'horace_eval', tmp_dir(), 'sqw' ...
            );
    else
        opts.outfile = cell(1,numel(win));
    end
end

func_handle = opts.func_handle;
pars = opts.pars;

end
