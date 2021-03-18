function obj = sqw_eval_pix_(obj, sqwfunc, ave_pix, pars)
% SQW_EVAL_PIX_
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
%
    %qw = calculate_qw_pixels2(win(i));
    qw = calculate_qw_pixels(obj);
    if ~ave_pix
        stmp = sqwfunc(qw{:}, pars{:});
    else
        % Get average h,k,l,e for the bin, compute sqw for that average, and fill pixels with the average signal for the bin that contains them
        qw_ave = obj.average_bin_data(qw);
        qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
        stmp = sqwfunc(qw_ave{:}, pars{:});
        stmp = replicate_array(stmp, obj.data_.npix);
    end
    obj.data_.pix.signal = stmp(:)';
    obj.data_.pix.variance = zeros(1,numel(stmp));
    obj = recompute_bin_data(obj);
end
