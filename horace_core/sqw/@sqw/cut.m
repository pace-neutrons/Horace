function wout = cut(obj, varargin)
%%CUT
%

% Add check that we can write to output file at beginning of algorithm

dnd_type = arrayfun(@(x) x.data.pix.num_pixels == 0, obj);
ndims_source = arrayfun(@(x) numel(x.data.pax), obj);

% If inputs have no pixels, delegate to cut_dnd
if all(dnd_type)
    wout = cell(1, numel(obj));
    for cut_num = 1:numel(obj)
        wout{cut_num} = cut_dnd_main(obj(cut_num), ndims_source(cut_num), varargin{:});
    end
    wout = [wout{:}];
    return
end

DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};
log_level = get(hor_config, 'log_level');

return_cut = nargout > 0;
[proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin{:});

if return_cut
    wout = allocate_output(opt.keep_pix, DND_CONSTRUCTORS, pbin);
end

for cut_num = 1:numel(obj)
    if return_cut
        wout(cut_num) = cut_single(obj(cut_num), proj, pbin, opt, log_level);
    else
        cut_single(obj(cut_num), proj, pbin, opt, log_level);
    end
end

if ~isempty(opt.outfile)
    if log_level >= 0
        disp(['Writing cut to output file ', opt.outfile, '...']);
    end
    try
        save_sqw(wout, opt.outfile);
    catch ME
        warning('CUT_SQW:io_error', ...
                'Error writing to file ''%s''.\n%s: %s', ...
                opt.outfile, ME.identifier, ME.message);
    end
end

end  % function


% -----------------------------------------------------------------------------
function out = allocate_output(keep_pix, dnd_constructors, pbin)
    max_pbin_dim = cellfun(@(x) max(size(x, 1), 1), pbin);
    non_unit_size = max_pbin_dim > 1;
    pbin_size_squeeze = [max_pbin_dim(non_unit_size) > 1, ...
                         ones(1, max(2 - sum(non_unit_size), 0))];
    if keep_pix
        out = repmat(sqw, pbin_size_squeeze);
    else
        num_out_dims = get_num_output_dims(pbin);
        out = repmat(dnd_constructors{num_out_dims + 1}(), pbin_size_squeeze);
    end
end


function [proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin)
    if ~all(ndims_source(1) == ndims_source)
        error('SQW:cut', ...
              ['Cannot cut sqw object with different dimensionality using ' ...
               'the same projection axis.']);
    end

    [ok, mess, ~, proj, pbin, args, opt] = cut_sqw_check_input_args( ...
        obj, ndims_source, return_cut, varargin{:} ...
    );
    if ~ok
        error ('CUT_SQW:invalid_arguments', mess)
    end

    if numel(obj) > 1 && ~isempty(opt.outfile)
        error('CUT_SQW:invalid_arguments', ...
              'You cannot make multiple cuts when specifying to output to a file.');
    end

    % Ensure there are no excess input arguments
    if numel(args) ~= 0
        error ('CUT_SQW:invalid_arguments', 'Check the number and type of input arguments')
    end
end


function save_sqw(sqw_obj, file_path)
    loader = sqw_formats_factory.instance().get_pref_access();
    loader = loader.init(sqw_obj, file_path);
    loader.put_sqw();
    loader.delete();
end


function num_dims = get_num_output_dims(pbin)
    % Get the number of dimensions in the output cut from the projection axis
    % binning.

    % pbin axes being integrated over will be an array with two elements - the
    % integration range - else the pbin element will have 1 or 3 elements
    non_integrated_axis = cellfun(@(x) numel(x) ~= 2, pbin);
    num_dims = sum(non_integrated_axis);
end
