function obj = sqw_eval_pix_(obj, sqwfunc, ave_pix, pars)
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
