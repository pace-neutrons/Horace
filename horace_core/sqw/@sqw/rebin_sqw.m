function wout = rebin_sqw(win, varargin)
%
% Rebin data in an sqw object, either with the boundaries specified by
% another object, or with a specified set of [lo,step,hi].
% Because a rebinnable sqw can have dimensionality 1-3, we have to do tests
% for quite a large number of scenarios. NB we decide not to do rebins on
% d0d (pointless).
%
% When working with sqw objects we can use the "MSlice approximation", i.e.
% that the size of the pixels is much smaller than the size of the bins, so
% that we just put all of the spectral weight from a given pixel into then
% bin where we find its centre.
%
% wout = rebin_sqw(win, [lo1,step1,hi1], [lo2,step2,hi2], ...) - rebin between
% specified limits with a given step size.
%
% wout = rebin_sqw(win, step1, step2, ...) - rebin with a given step size.
%
% wout = rebin_sqw(win, w2) - rebin using the bin boundaries of object w2,
% which is either an sqw of the same dimensionality, or a dnd.
%
%
% RAE 21/1/10

    if ~isa(win, 'sqw')
        %what we should actually do here is go to the dnd-rebin of correct
        %dimensionality
        error('HORACE:rebin_sqw:invalid_argument', ...
              'input object must be sqw type with detector pixel information');
    end

    if isempty(varargin)
        error('HORACE:rebin_sqw:invalid_argument', ...
              'requires at least one other argument');
    end

    use_template_object = isa(varargin{1},'SQWDnDBase');

    % Turn off horace_info output, but save for automatic clean-up on exit or cntl-C (TGP 30/11/13)
    info_level = get(hor_config,'log_level');
    cleanup_obj = onCleanup(@()set(hor_config,'log_level',info_level));
    set(hor_config,'log_level',-1);

    if use_template_object

        if ~isscalar(varargin) || ~isscalar(varargin{1})
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'If using template argument, only one should be supplied');
        end

        w2 = varargin{1};

        %rebinning with a template object. this is the most complicated
        %case

        data = win.data;

        if isa(w2, 'DnDBase')
            data2 = w2;
        elseif isa(w2, 'sqw')
            data2 = w2.data;
        end

        ndims = dimensions(win);
        ndims2 = dimensions(w2);

        if ndims ~= ndims2
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'dimensionality of object to be rebinned and template object must be the same');
        end

        %must check that the (hyper) plane described by the data axes for
        %both objects is the same. Simplest case is that they have the same
        %axes, but in principle it is OK if we just have the same plane.
        %e.g. a 2d object could be rebinned from (1,0,0)/(0,1,0) to
        %(1,1,0)/(-1,1,0)

        if data.proj ~= data2.proj
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'input sqw and template object projections misaligned');
        end

        ax = data.axes;
        ax2 = data2.axes;

        %have parallel axes, so can proceed
        minmax = minmax_ranges(ax.img_range, ...
                               ax2.img_range);

        bins = cell(ndims, 1);
        step = ax2.step;

        for i = 1:ndims
            bins{i} = [minmax(1, data.pax(i)), step(i), minmax(2, data.pax(i))];
        end

    else

        vec_or_empty = cellfun(@(x) isvector(x) || isempty(x), varargin);
        if ~all(vec_or_empty)
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'check the format of input arguments');
        end

        %rebinning x and/or y and/or z axes
        bins = cellfun(@check_bin, varargin, 'UniformOutput', false);

        ndims = dimensions(win);

        if ndims < numel(bins)
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'have specified %d or more binning arguments for a %d-dimensional object', ...
                  numel(bins), ndims);
        end

    end

    % Pad with empty bins
    bins = {bins{:} [] [] [] []};

    wout = cut(win, bins{1:ndims});


end

function bin = check_bin(bin)
    switch numel(bin)
      case 1
        %just a step size specified for x
      case 3
        %lo,step,hi
        if bin(1) >= bin(3) || (bin(3) - bin(1)) < bin(2)
            error('HORACE:rebin_sqw:invalid_argument', ...
                  'problem with specified x-bins. Must be of form [step] or [lo,sttep,hi]');
        end
      otherwise
        bin = [];
    end
end
