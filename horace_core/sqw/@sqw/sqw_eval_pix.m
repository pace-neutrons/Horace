function obj = sqw_eval_pix(obj, sqwfunc, ave_pix, pars, outfilecell, i)
%==================================================================================================
% SQW_EVAL_PIX
%
% Helper function for sqw eval executed on a pixel-less object (i.e. DnD or SQW with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc    Handle to function that calculates S(Q,w)
%   ave_pix    Boolean flag wither to apply function to averaged bin data
%   pars       Arguments needed by the function.
%   outfile    The file used for filebacking and output
%
%==================================================================================================

if obj.pix.is_filebacked
    outfile = outfilecell{i};
    if ave_pix
        obj = do_sqw_eval_average_filebacked_( ...
            obj, sqwfunc, pars, outfile ...
            );
    else
        obj = do_sqw_eval_file_backed_( ...
            obj, sqwfunc, pars, outfile ...
            );
    end
else
    obj = do_sqw_eval_in_memory_(obj, sqwfunc, pars, ave_pix);
    if ~isempty(outfilecell) && ~isempty(outfilecell{i})
        save(obj, outfilecell{i});
    end
end

end % of function sqw_eval_pix_

%-------------------------------------------------------------------------------------------------------
function wout = do_sqw_eval_in_memory_(wout, sqwfunc, pars, average)
% Perform sqw_eval on an sqw object with all its pixels in memory
%
qw_pix_coords = calculate_qw_pixels(wout);
if average
    % Get average h, k, l, e for the bin, compute sqw for that average,
    % and fill pixels with the average signal for the bin that contains
    % them
    qw_ave = average_bin_data(wout, qw_pix_coords);
    qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
    new_signal = sqwfunc(qw_ave{:}, pars{:});
    new_signal = repelem(new_signal, wout.data.npix(:));
else
    new_signal = sqwfunc(qw_pix_coords{:}, pars{:});
end

wout.pix_.signal = new_signal(:)';
wout.pix_.variance = zeros(1, numel(new_signal));
wout = recompute_bin_data(wout);

end