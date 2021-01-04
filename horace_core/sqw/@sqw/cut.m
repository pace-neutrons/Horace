function wout = cut(obj, varargin)
%%CUT
%
DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};

if numel(obj) > 1
    error('SQW:cut', ...
          ['You cannot take a cut from an array, or cell array, of sqw or ' ...
           'dnd object.\nConsider cutting the objects in a loop.']);
end

dnd_type = obj.data.pix.num_pixels == 0;
ndims_source = numel(obj.data.pax);

if dnd_type
    % Inputs have no pixels, delegate to cut_dnd
    % TODO: refactor so cut_dnd_main sits on DnDBase class
    wout = cut_dnd_main(obj, ndims_source, varargin{:});
    return
end

return_cut = nargout > 0;
[proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin{:});

% Process projection
[proj, pbin, ~, pin, en] = update_projection_bins( ...
    proj, obj.header, obj.data, pbin ...
);

sz = cellfun(@(x) max(size(x, 1), 1), pbin);
if return_cut
    wout = allocate_output(sz, pbin, opt.keep_pix, DND_CONSTRUCTORS);
end

for cut_num = 1:prod(sz)
    pbin_tmp = get_pbin_for_cut(sz, cut_num, pbin);
    args = {obj, proj, pbin_tmp, pin, en, opt.keep_pix, opt.outfile};
    if return_cut
        wout(cut_num) = cut_single(args{:});
    else
        cut_single(args{:});
    end
end

end  % function


% -----------------------------------------------------------------------------
function [proj, pbin, opt] = validate_args(obj, return_cut, ndims_source, varargin)
    [ok, mess, ~, proj, pbin, args, opt] = cut_sqw_check_input_args( ...
        obj, ndims_source, return_cut, varargin{:} ...
    );
    if ~ok
        error ('CUT_SQW:invalid_arguments', mess)
    end

    % Ensure there are no excess input arguments
    if numel(args) ~= 0
        error ('CUT_SQW:invalid_arguments', ...
               'Check the number and type of input arguments')
    end
end


function [proj, pbin, num_dims, pin, en] = update_projection_bins( ...
        proj, sqw_header, data, pbin)
    % Update projection bins using the sqw header
    header_av = header_average(sqw_header);
    [proj, pbin, num_dims, pin, en] = proj.update_pbins(header_av, data, pbin);
end


function num_dims = get_num_output_dims(pbin)
    % Get the number of dimensions in the output cut from the projection axis
    % binning.

    % pbin axes being integrated over will be an array with two elements - the
    % integration range - else the pbin element will have 1 or 3 elements
    % if pbin{x} has more than 3 elements then we are doing a multicut and that
    % axis is being integrated over.
    % The ~isempty catches any dummy axes that are 0x0 doubles.
    is_non_int_axis = @(x) numel(x) ~= 2 && numel(x) < 4 && ~isempty(x);
    non_integrated_axis = cellfun(is_non_int_axis, pbin);
    num_dims = sum(non_integrated_axis);
end


function out = allocate_output(sz, pbin, keep_pix, dnd_constructors)
    sz_squeeze = [sz(sz > 1), ones(1, max(2 - sum(sz > 1), 0))];
    if keep_pix
        out = repmat(sqw, sz_squeeze);
    else
        out_dims = get_num_output_dims(pbin);
        out = repmat(dnd_constructors{out_dims + 1}(), sz_squeeze);
    end
end


function pbin_out = get_pbin_for_cut(sz, cut_num, pbin_in)
    % Get pbin for each cut (allow for a bin descriptor being empty)
    ind_subs = cell(1, 4);
    [ind_subs{:}] = ind2sub(sz, cut_num);
    pbin_out = cell(1,4);
    for i = 1:numel(pbin_out)
        if ~isempty(pbin_in{i})
            pbin_out{i} = pbin_in{i}(ind_subs{i}, :);
        else
            pbin_out{i} = pbin_in{i};
        end
    end
end
