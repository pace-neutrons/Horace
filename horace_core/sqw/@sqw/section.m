function wout = section (win,varargin)
% Takes a section out of an sqw object
%
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], ...)
%
% Input:
% ------
%   win                 Input sqw object
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%           :                       :
%
%       for as many axes as there are plot axes
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first and third axes of a 3D sqw object:
%   >> wout = section (win, [1.9,2.1], [], [-0.55,-0.45])


% Original author: T.G.Perring
%


% Trivial case of no section arguments
if nargin==1
    wout = copy(win);
    return
end

% Dimension of input data structures
ndim=dimensions(win(1));
if ndim==0  % no sectioning possible
    error('HORACE:sqw:invalid_argument', 'Cannot section a zero dimensional object')
end

if numel(win) > 1 && any(arrayfun(@dimensions, win(2:end)) ~= ndim)
    error('HORACE:sqw:invalid_argument', 'All objects must have same dimensionality for sectioning to work')
end

if length(varargin) ~= ndim
    error('HORACE:sqw:invalid_argument', 'Check number of arguments')
end

% Initialise output argument
wout = copy(win);

tol=4*eps('single');    % acceptable tolerance: bin centres deemed contained in new boundaries

for n=1:numel(win)

    [ndim,sz]=dimensions(win(n));   % need to get sz array specific for each element in array win

    % Get section parameters and axis arrays:
    % The input sectioning arguments refer to the *display* axes; these must be converted to the relevant plot axes in the algorithm
    irange = zeros(2,ndim);
    array_section = cell(1,ndim);

    % extract bin boundaries
    p=win(n).data.p;

    nbins_all_dims = win(n).data.axes.nbins_all_dims;
    img_range = win(n).data.axes.img_range;

    % Range for selecting appropriate bins
    cut_range = img_range;

    % find directions which are plot/projection indices
    % i.e. have bins
    p_ind = find(nbins_all_dims > 1);

    for i=1:ndim

        curr_range = varargin{i};
        pax = win(n).data.dax(i);

        if isempty(curr_range) || isequal(curr_range, [0])

            irange(1,pax) = 1;
            irange(2,pax) = sz(pax);
            array_section{pax} = irange(1,pax):irange(2,pax);

        elseif numel(curr_range) == 2

            if curr_range(1) > curr_range(2)
                error ('HORACE:section:invalid_argument', ...
                       'Lower limit larger than upper limit for axis %d',i)
            end

            % values of bin centres
            pcent = 0.5*(p{pax}(2:end)+p{pax}(1:end-1));

            % index of bins whose centres lie in the sectioning range
            lis=find(pcent >= (curr_range(1)-tol) & pcent <= (curr_range(2)+tol));

            if isempty(lis)
                error ('HORACE:section:invalid_argument', ...
                       'No data along axis %d in the range [%g, %g]', ...
                       i, curr_range(1), curr_range(2))
            end

            irange(1,pax) = lis(1);
            irange(2,pax) = lis(end);
            img_range(:,p_ind(pax)) = [p{pax}(irange(1,pax))
                                       p{pax}(irange(2,pax)+1)];

            cut_range(:,p_ind(pax)) = [pcent(irange(1,pax))
                                 pcent(irange(2,pax))];

            nbins_all_dims(p_ind(pax)) = irange(2,pax) - irange(1,pax)+1;

            %wout(n).data.p{pax} = p{pax}(lis(1):lis(end)+1);
            array_section{pax}=irange(1,pax):irange(2,pax);

        else
            error ('HORACE:section:invalid_argument', ...
                   'Limits for axis %d must be [], [0] or [min max]', i)
        end
    end

    new_axis_block = ortho_axes('nbins_all_dims',nbins_all_dims,...
                                'img_range',cut_range, ... % binning img_range temporarily
                                'single_bin_defines_iax', win(n).data.axes.single_bin_defines_iax, ...
                                'ulen', win(n).data.axes.ulen);

    % Section signal, variance and npix arrays
    data = DnDBase.dnd(new_axis_block, win(n).data.proj, ...
                       squeeze(win(n).data.s(array_section{:})), ...
                       squeeze(win(n).data.e(array_section{:})), ...
                       squeeze(win(n).data.npix(array_section{:})));
    data.axes.img_range = img_range;
    wout(n).data = data;

    % Section the pix array, if sqw type, and update img_range
    if has_pixels(win(n))

        % get contiguous ranges of pixels to be retained
        [bl_start,bl_size] = get_nrange(win(n).data.proj, ...
                                        win(n).data.npix, ...
                                        win(n).data.axes, ...
                                        new_axis_block, ...
                                        win(n).data.proj);

        wout(n).pix = win(n).pix.get_pix_in_ranges(bl_start,bl_size);
    end

end
