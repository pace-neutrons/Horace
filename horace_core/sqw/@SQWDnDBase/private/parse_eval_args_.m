function [func_handle, pars, opts] = parse_eval_args_(win, func_handle, pars, varargin)
%
flags = {'-all', '-average', '-filebacked'};
[~, ~, all_flag, ave_flag, filebacked_flag, args] = parse_char_options(varargin, flags);

parser = inputParser();
parser.addRequired('func_handle', @(x) isa(x, 'function_handle'));
parser.addRequired('pars');
parser.addParameter('average', ave_flag, @islognumscalar);
parser.addParameter('all', all_flag, @islognumscalar);
parser.addParameter('filebacked', filebacked_flag, @islognumscalar);
parser.addParameter('outfile', {}, @(x) iscellstr(x) || istext(x));

parser.parse(func_handle, pars, args{:});
opts = parser.Results;

if ~iscell(opts.pars)
    opts.pars = {opts.pars};
end
if ~iscell(opts.outfile)
    opts.outfile = {opts.outfile};
end

outfiles_empty = all(cellfun(@(x) isempty(x), opts.outfile));
if ~outfiles_empty && (numel(win) ~= numel(opts.outfile))
    error( ...
        'HORACE:sqw:invalid_arguments', ...
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
