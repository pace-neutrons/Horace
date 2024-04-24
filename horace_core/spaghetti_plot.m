function varargout = spaghetti_plot(varargin)
% Plots the data in an sqw file or object along a path in reciprocal space
%
%   >> spaghetti_plot(rlp,data_source)
%   >> spaghetti_plot(wdisp)
%
%   >> spaghetti_plot(...,'labels',{'G','X',...})            % customised labels
%   >> spaghetti_plot(...,'smooth',1)                        % smooth data with this width
%   >> spaghetti_plot(...,'smooth_shape','hat')              % smooth data with this shape
%   >> spaghetti_plot(...,'qbin',qb)                         % specify q bin size in 1/Ang
%   >> spaghetti_plot(...,'qwidth',qi)                       % specify q integration width in 1/Ang
%   >> spaghetti_plot(...,'qwidth', [0.1; 0.3; ...])         % square q integration for each segment
%   >> spaghetti_plot(...,'qwidth', [0.1 0.1; 0.3 0.1; ...]) % q integration for each segment
%   >> spaghetti_plot(...,'ebin',[elo estp ehi])             % specify energy bin in meV
%   >> spaghetti_plot(...,'logscale')                        % plots intensity in log10 scale
%   >> spaghetti_plot(...,'clim',[cmin cmax])                % sets the colorscale (needed for logscale)
%
%   >> wdisp = spaghetti_plot(...)                           % outputs the cuts as a d2d array
%   >> wdisp = spaghetti_plot(...,'noplot')                  % outputs arrays without plotting
%
%   >> [wdisp,cuts] = spaghetti_plot(...)                    % generates a set of 1D cuts
%   >> [wdisp, cuts] = spaghetti_plot(...,'withpix')         % return cuts as sqw rather than d1ds
%
% Input:
% ------
%   rlp             Array of r.l.p. e.g. [0,0,0; 0,0,1; 1,0,1; 1,0,0];
%
%   data_source     Data source: sqw object or filename of a file with sqw-type data
%                     (character string or cellarray with one character string)
%
%   wdisp           Array of d2d objects containing the cuts - e.g. previous generated
%                   spaghetti plot.
%
% Keyword options (can be abbreviated to single letter):
%
%   'labels'        Tick labels to place at the positions of the Q points in
%                     argument rlp.
%                     e.g. {'G','X','M','R'}
%                   By default the labels are character representations of rlp
%                     e.g. {0,0,0; 0.5,0,0; 0.5,0.5,0; 0.5,0.5,0.5}
%                     becomes
%                          {'0,0,0', '0.5,0,0', '0.5,0.5,0', '0.5,0.5,0.5'}
%
%   'smooth'        Applies smoothing to the cuts. The parameter specifies the smoothing
%                     width (default = 0 ; i.e. no smoothing)
%
%   'smooth_shape'  Applies smoothing to the cuts with this functions. (default: 'hat')
%                     'hat'        hat function
%                                  - width gives FWHH along each dimension in pixels
%                                  - width = 1,3,5,...;  n=0 or 1 => no smoothing
%                     'gaussian'   Gaussian
%                                  - width gives FWHH along each dimension in pixels
%                                  - elements where more than 2% of peak intensity
%                                    are retained
%
%                     'resolution' Correlated Gaussian (suitable for e.g. powder data)
%
%                   Note that smoothing only works on initial cuts, not with reploting
%
%   'qbin'          Size of momentum transfer bins in 1/Ang (default = 0.05)
%
%   'qwidth'        Integration width for q-directions perpendicular to the desired q
%                     in 1/Ang. This may either be a scalar which will be applied to
%                     both perpendicular directions, or a 2-vector [dqv dqw] with dqv
%                     being the width in v, and dqw the width in w (see below)
%                     (default = 0.1)
%
%                   A qwidth can be specified in either form for each segment, this
%                   must match the number of segments (nrlp - 1)
%
%   'ebin'          The energy bin parameters in meV as a 3-vector [min, step, max]
%                     (default: use energy bins in data_source)
%
%   'logscale'      Plots the data in a logarithmic (base 10) scale if true
%
%   'clim'          A 2-vector giving the signal (colour) value limits. This is needed
%                     if using 'logscale' as this breaks the interactive slider.
%                     (default: [NaN NaN] - use limits of data)
%
%   'cuts_plot_size' under normal operation, the width of every part of
%                   spaghetti plot is proportional to the physical distance (A^-1)
%                   between various points in reciprocal space (the rlp
%                   parameter)
%                   This parameter should be followed by the list of the
%                   relative plot widths, every panel of the spaghetti
%                   plot would occupy. E.g. If your rlp are
%                   [0,0,0;1,0,0;1/2,1/2,0], the X-sizes of the plot
%                   [0,0,0]->[1,0,0] and [1,0,0]->[1/2,1/2,0] would be
%                   related as 1 to 1/sqrt(2) (in Cubic lattice). If you provide
%                   cuts_plot_size array equal [1,1], the length of X-axis
%                   on the each q-panel plot would be equal.
%
%                   TODO: big changes in the width of the sub-plots will
%                   cause big difference in the sub-plot resolution. The
%                   changes in the plot width should cause changes in qbin too.
%
%   'withpix'      If cuts are returned this will return full sqw objects with
%                   pixel information rather than d1d image objects.
%
% Output:
% -------
%   wdisp       Array of d2d objects containing the cuts, one per q-segment.
%
%   cuts        Array of d1d|sqw objects of energy cuts along the hkl-lines
%
% The function determines the q-directions for cuts of the sqw object as follows:
%   u is the direction between the desired q-points specified in rlp
%   v is the direction perpendicular to u and c* (or u and a* if u||c*)
%   w is the direction perpendicular to u and v
%
% However, if the function detects that all the rlp lies in a plane (e.g. a*-b*) then
% it will set v to be perpendicular to this plane for all segments.

% Original author: M. D. Le
%

% TODO: Make it work for dnd objects (no arbitrary projections...)

% Set defaults
% ------------
arglist = struct('qbin', 0.05, ...
                 'qwidth', 0.1, ...
                 'ebin', [], ...
                 'labels', '', ...
                 'noplot', false, ...
                 'smooth', 0, ...
                 'smooth_shape', 'hat',...
                 'logscale', false, ...
                 'clim', [NaN NaN], ...
                 'cuts_plot_size', [], ...
                 'withpix', false);
flags = {'noplot', 'logscale', 'withpix'};

% Parse the arguments:
% --------------------
[args, opt, present] = parse_arguments(varargin, arglist, flags);

if numel(args) == 1 && (isa(args{1}(1), 'd2d') || isa(args{1}(1), 'IX_dataset_2d'))
    plot_dispersion(args{1}, opt);
    return
elseif numel(args) > 1 && isa(args{2}(1), 'd2d')
    plot_dispersion(args{2}, opt);
    return
end

if numel(args) ~= 2
    error('HORACE:spaghetti_plot:invalid_argument', ...
          'Invalid number of arguments')
end

rlp = args{1};
num_rlp = size(rlp, 1);
nseg = num_rlp - 1;
sqw_in = args{2};

if size(rlp, 2) ~= 3 || num_rlp < 2
    error('HORACE:spaghetti_plot:invalid_argument', ...
          'Array should contain at least 2 rlp arranged in an [Nx3] array, received size: %s;', ...
          disp2str(size(rlp)))
end

if present.cuts_plot_size
    if nseg ~= numel(opt.cuts_plot_size)
        error('HORACE:spaghetti_plot:invalid_argument', ...
              [' the size of the cut_plot_dist array should be one less than the number of rlp points.'...
               ' In fact the number of rlp is %d and the number of distances is %d'], ...
              num_rlp, numel(opt.cuts_plot_size));
    end

    invalid = opt.cuts_plot_size <= 0;
    if any(invalid)
        error('HORACE:spaghetti_plot:invalid_argument', ...
              'the plot sizes should be positive numbers but some of them are: %g; %g; %g; %g; %g', ...
              opt.cuts_plot_size(invalid));
    end
end

if isa(sqw_in, 'sqw')
    % pass
elseif istext(sqw_in) && is_file(sqw_in)
    sqw_in = sqw(sqw_in);
else
    error('HORACE:spaghetti_plot:invalid_argument', ...
          'Check argument giving data source. Must be an sqw object or sqw file')
end

qbin = opt.qbin;
qwidth = opt.qwidth;
siz = size(opt.qwidth);

if isequal(siz, [1, 1])                % "Square" for all segments
    qwidth = repmat(opt.qwidth, 2, nseg);
elseif isequal(siz,  [1, 2]) || ...    % Rectangular for all segments
        isequal(siz, [2, 1])
    qwidth = repmat(opt.qwidth(:), 1, nseg);
elseif isequal(siz,  [nseg, 1]) || ... % "Square" for each segment
        isequal(siz, [1, nseg])
    qwidth = repmat(opt.qwidth(:)', 2, 1);
elseif isequal(siz,  [2, nseg])        % Rectangular for each segments
    qwidth = reshape(opt.qwidth, 2, nseg);
else
    error('HORACE:spaghetti_plot:invalid_argument', ...
          ['qwidth size must be one of: [1, 1], [2, 1], [1, nseg], or [2, nseg].\n' ...
           'Received: %s'], disp2str(opt.qwidth))
end

ebin = opt.ebin;

% Make labels
% ------------
if present.labels && (isempty(opt.labels) || ~iscellstr(opt.labels) || numel(opt.labels) ~= num_rlp)
    error('HORACE:spaghetti_plot:invalid_argument', ...
        'Check number of user-supplied labels and that they form a cell array of strings');
end

% Some initialising
%------------------
sqw_proj = sqw_in.data.proj;

% Checks if all the rlp's are in a plane
%---------------------------------------
plane_normal = [];

if nseg > 1
    u1rlp = rlp(1, :) - rlp(2, :);
    u2rlp = rlp(2, :) - rlp(3, :);

    u1crt = sqw_proj.transform_hkl_to_img(u1rlp')';
    u2crt = sqw_proj.transform_hkl_to_img(u2rlp')';
    normal_vector = cross(u1crt, u2crt);

    % Check if rlp's are collinear.
    for j = 3:nseg
        if abs(sum(normal_vector)) >= min(opt.qbin) / 100
            break
        end
        u2rlp = rlp(j,:)-rlp(j+1,:);
        u2crt = sqw_proj.transform_hkl_to_img(u2rlp')';
        normal_vector = cross(u1crt, u2crt);
    end
    plane_normal = normal_vector;

    for i = j:nseg
        u2rlp = rlp(i, :) - rlp(i+1, :);
        u2crt = sqw_proj.transform_hkl_to_img(u2rlp')';
        normal_vector = cross(u1crt, u2crt);

        if abs(sum(cross(normal_vector, plane_normal))) > 1e-5 % and are coplanar.
            plane_normal = [];
            break
        end

    end
end


if ~isempty(plane_normal)
    fprintf('spaghetti_plot: rlp found to lie in the plane perpendicular to (%g %g %g)\n', ...
            sqw_proj.transform_img_to_hkl(plane_normal'));
end


% Loop over rlp, determines the projections and make the cuts
%------------------------------------------------------------
xrlp = 0;
wdisp = repmat(d2d, 1, nseg);

bz_norm = sqw_proj.transform_hkl_to_pix([0;0;1]);
bz_norm = bz_norm ./ norm(bz_norm);

bx_norm = sqw_proj.transform_hkl_to_pix([1;0;0]);
bx_norm = bx_norm ./ norm(bx_norm);

for i = 1:nseg
    q_dir_rlu = rlp(i+1, :) - rlp(i, :);

    q_dir_abs = sqw_proj.transform_hkl_to_pix(q_dir_rlu')';
    q_dir_abs = q_dir_abs ./ norm(q_dir_abs);

    q_start_abs = sqw_proj.transform_hkl_to_pix(rlp(i, :)')';
    q_end_abs = sqw_proj.transform_hkl_to_pix(rlp(i+1, :)')';


    if isempty(plane_normal)
        dqv_abs = cross(q_dir_abs, bz_norm);
        if sum(abs(dqv_abs)) < min(opt.qbin) / 100
            dqv_abs = cross(q_dir_abs, bx_norm);
        end
    else
        dqv_abs = ortho_vec(q_dir_abs);
    end

    dqv_abs = dqv_abs ./ norm(dqv_abs);
    dqw_abs = cross(q_dir_abs, dqv_abs);
    q_dir_frac = sqw_proj.transform_pix_to_hkl(q_dir_abs')';
    dqv_frac = sqw_proj.transform_pix_to_hkl(dqv_abs')';
    dqw_frac = sqw_proj.transform_pix_to_hkl(dqw_abs')';

    ulen = 1 ./ vecnorm(inv(ubmatrix(q_dir_frac, dqv_frac, sqw_proj.bmatrix)));

    q_dir_rs = q_dir_frac .* ulen(1);
    dqv_rs = dqv_frac .* ulen(2);
    dqw_rs = dqw_frac .* ulen(2);

    proj = line_proj(q_dir_rs, ...
                     dqv_rs, ...
                     dqw_rs, ...
                     'type', 'rrr');

    % determines the bin size in the desired q-direction in r.l.u.
    u1bin = qbin / ulen(1);

    % determines the integration range over the perpendicular q-directions in r.l.u.
    u2bin = qwidth(1, i) / ulen(2);
    u3bin = qwidth(2, i) / ulen(3);

    u20 = dot(q_start_abs, dqv_abs) / ulen(2);
    u30 = dot(q_start_abs, dqw_abs) / ulen(3);
    u1 = [dot(q_start_abs, q_dir_abs) / ulen(1), ...
          u1bin, ...
          dot(q_end_abs, q_dir_abs) / ulen(1)];

    % Radu Coldea on 19/12/2018: adjust qbin size to have an exact
    % integer number of bins between the start and end points
    u1(2) = (u1(3) - u1(1)) / floor((u1(3) - u1(1)) / u1(2));
    u2 = [u20 - u2bin, u20 + u2bin];
    u3 = [u30 - u3bin, u30 + u3bin];

    % Make cut, and save to array of d2d

    wdisp(i) = cut(sqw_in, proj, u1, u2, u3, ebin);

    if nargout > 1

        u1v = u1(1):u1(2):u1(3);

        if wdisp(i).has_pixels()
            for j=1:numel(u1v)-1
                varargout{2}{i}(j) = cut(wdisp(i), u1v(j:j+1), []);
            end
        else
            varargout{2}{i} = repmat(sqw(), 1, numel(u1v)-1);
        end

    end

    if ~opt.withpix
        wdisp(i) = d2d(wdisp(i));
        if nargout > 1
            varargout{2}{i} = cellfun(@d1d, varargout{2}{i});
        end
    end

    if present.labels
        titlestr = sprintf('Segment from "%s" (%f %f %f) to "%s" (%f %f %f)', ...
                           opt.labels{i}, rlp(i, :), opt.labels{i+1}, rlp(i+1, :));
    else
        titlestr = sprintf('Segment from (%f %f %f) to (%f %f %f)', ...
                           rlp(i, :), rlp(i+1, :));
    end

    if i > 1
        wdisp(i).title = titlestr;
    else
        binstr = sprintf(['q bin size approximately %f ', char(197), '^{-1}'], opt.qbin);
        if numel(opt.qwidth)==1 || numel(opt.qwidth) == nseg
            wdisp(i).title=sprintf(['integrated over %f ', char(197), ...
                '^{-1} in perpendicular q-directions\n%s\n%s'], qwidth(1, i), binstr, titlestr);
        else
            wdisp(i).title=sprintf(['integrated over %f ', char(197), ...
                '^{-1} in qv and %f ', char(197), '^{-1} in qw\n%s\n%s'], qwidth(:, i), binstr, titlestr);
        end
    end


end

if nargout > 0
    varargout{1}=wdisp;
end

% Plot dispersion
%----------------
if nargout < 1
    plot_dispersion(arrayfun(@d2d, wdisp),opt)
end

end

%========================================================================================================
function plot_dispersion(wdisp_in,opt)
% Plots the dispersion in the structure wdisp

if opt.noplot
    return
end

scale_x_axis = ~isempty(opt.cuts_plot_size);

qinc = 0;
title1 = wdisp_in(1).title;

if iscell(title1)
    title1 = title1{1};
end

lnbrk = strfind(title1, newline);

if ~isempty(lnbrk)
    lnbrk = lnbrk(end);
    wdisp_in(1).title = title1(lnbrk+1:end);
end

is_ix_dataset = isa(wdisp_in, 'IX_dataset_2d');

% Internally use IX_dataset_2d to manipulate the x-axis (flip and adjust bin boundaries)
if is_ix_dataset
    wdisp = wdisp_in;
elseif opt.smooth > 0  % smooth does not work for IX_datasets.
    wdisp = arrayfun(@(x) IX_dataset_2d(smooth(x, opt.smooth, opt.smooth_shape)), wdisp_in);
else
    wdisp = arrayfun(@IX_dataset_2d, wdisp_in);
end

for i=1:length(wdisp_in)

    if numel(wdisp(i).x) == size(wdisp(i).signal, 1)+1
        % For plotting, change bin edges to bin centres
        bin_centers = 0.5*(wdisp(i).x(1:end-1)+wdisp(i).x(2:end));
    else
        % Already bin centres
        bin_centers  = wdisp(i).x;
    end

    if scale_x_axis
        % scale plot axis according to the scales provided
        min_bc = min(bin_centers);
        scale_size  = max(bin_centers)-min_bc;
        scale = opt.cuts_plot_size(i);
        wdisp(i).x = qinc + (bin_centers-min_bc)*(scale / scale_size);
    elseif is_ix_dataset
        wdisp(i).x = qinc + (bin_centers-bin_centers(1));
    else
        ulen = wdisp_in(i).ulen;
        % Converts the x-axis from r.l.u. along the segment q-direction to incremental |q| in 1/Ang
        wdisp(i).x = qinc + (bin_centers-bin_centers(1))*ulen(1);
    end

    qinc = wdisp(i).x(end);

    % Update current segment length for labelling position.
    wdisp(i).x_axis = IX_axis('Momentum', [char(197), '^{-1}']);
    wdisp(i).y_axis = IX_axis('Energy', 'meV');

    if is_ix_dataset
        labels{i} = wdisp(i).title{1};
        continue;
    end

    % Finds labels in segment title
    title = wdisp_in(i).title;
    brk = strfind(title, newline);

    if ~isempty(brk)
        brk = brk(end);
        wdisp_in(i).title = title(brk+1:end);
    end

    try
        bra = strfind(title, '(');
        ket = strfind(title, ')');
        hkls = [sscanf(title(bra(1):ket(1)), '(%f %f %f)');
                sscanf(title(bra(2):ket(2)), '(%f %f %f)')];
        quotes = strfind(title, '"');

        % hkl points for segments previous and current do not match'
        if i > 1 && ~equal_to_tol(hkls(1:3), hkl0(4:6), 'tol', 1e-2)
            if isempty(quotes)
                labels{i} = sprintf('[%s]/[%s]', str_compress(num2str(hkl0(4:6)')), str_compress(num2str(hkls(1:3)')));
            else
                labels{i} = sprintf('%s/%s', labels{i}, title(quotes(1)+1:quotes(2)-1));
            end
        elseif isempty(quotes)
            labels{i} = ['[', str_compress(num2str(hkls(1:3)'), ', '), ']'];
        else
            labels{i} = title(quotes(1)+1:quotes(2)-1);
        end

        if isempty(quotes)
            labels{i+1} = ['[', str_compress(num2str(hkls(4:6)'), ', '), ']'];
        else
            labels{i+1} = title(quotes(3)+1:quotes(4)-1);
        end
    catch
        hkldir = wdisp_in(i).u_to_rlu(1:3, 1);
        inthkl = kron(wdisp_in(i).iint', wdisp_in(i).u_to_rlu(:, wdisp_in(i).iax));
        hklcen = sum([mean(inthkl(1:3, [1 3]), 2), mean(inthkl(5:7, [2 4]), 2)], 2);
        hkls = [wdisp_in(i).p{1}(1) * hkldir + hklcen; ...
                wdisp_in(i).p{1}(end) * hkldir + hklcen];
        labels{i} = ['[', str_compress(num2str(hkls(1:3)'), ', '), ']'];
        labels{i+1} = ['[', str_compress(num2str(hkls(4:6)'), ', '), ']'];

    end

    hkl0 = hkls;
end

% This might not be the best way to do this but the 2D dataset should(!) hopefully not
%   take up too much memory to make a copy of wdisp...
if opt.logscale
    for i=1:length(wdisp)
        wdisp(i).signal = log10(wdisp(i).signal);
    end
end

wdisp(1).title = title1(1:lnbrk);

plot(wdisp);
hold on;

xrlp = zeros(length(wdisp) + 1, 1);

for i=1:length(wdisp)
    xrlp(i+1) = wdisp(i).x(end);
    plot([1 1] * xrlp(i+1), get(gca,'YLim'), '-k');
end

hold off;

if ~isempty(opt.labels)
    if ~iscellstr(opt.labels) || numel(opt.labels) ~= length(wdisp)+1
        warning('HORACE:bad_labels', ...
                ['Not using user-supplied labels. They are either not a cell array of' ...
                 'strings or not enough for all segments']);
    end

    labels = opt.labels;
end

plot_labels(labels, xrlp);

if sum(isnan(opt.clim)) ~= 2
    if opt.logscale
        clim = log10(opt.clim);
    else
        clim = opt.clim;
    end
    caxis(clim);
    chld = get(gcf, 'Children');
    set(findobj(chld, 'tag', 'color_slider_min_value'), 'String', num2str(opt.clim(1)));
    set(findobj(chld, 'tag', 'color_slider_max_value'), 'String', num2str(opt.clim(2)));
end

if opt.logscale

    if sum(isnan(opt.clim))~=2
        clim = opt.clim;
    else
        clim = 10.^get(gca, 'CLim');
        chld = get(gcf, 'Children');
        set(findobj(chld, 'tag', 'color_slider_min_value'), 'String', num2str(clim(1)));
        set(findobj(chld, 'tag', 'color_slider_max_value'), 'String', num2str(clim(2)));
    end

    hc=colorbar;

    set(hc, 'TicksMode', 'manual');

    step = 9;

    majorticks = ceil(log10(clim(1))):floor(log10(clim(2)));

    unitbefore = 10^majorticks(1) / 10;
    unitafter = 10^majorticks(end);

    tickstart = ceil(clim(1)*unitbefore) / unitbefore;
    tickend = floor(clim(2)*unitafter) / unitafter;

    ticksbefore = tickstart:unitbefore:unitbefore*9;
    ticksafter = unitafter:unitafter:tickend;

    ntick = (numel(majorticks) - 1) * step;
    ntick = ntick + numel(ticksbefore) + numel(ticksafter);

    ticklabels = cell(1,ntick);
    offset = numel(ticksbefore);

    minorticks = zeros(1,ntick);
    minorticks(1:offset) = ticksbefore;

    tick_index = offset + 1;

    for i=0:numel(majorticks)-2
        unit = 10^majorticks(i+1);
        tick_index = tick_index + step;
        minorticks(tick_index:tick_index + step) = [unit:unit:step*unit];
        ticklabels{tick_index} = num2str(unit);
    end

    tick_index = tick_index + step

    minorticks(tick_index:end) = ticksafter;
    ticklabels{tick_index} = num2str(10^majorticks(end));

    set(hc, 'Ticks', log10(minorticks));
    set(hc, 'TickLabels', ticklabels);
end

end

function plot_labels(labels,xvals)
% Labels for plots.
%
%   >> plot_labels(labels, ndiv)
%
%   labels      cell array of labels
%   xvals       positions for the labels

set(gca, 'XTick', xvals);
set(gca, 'XTickLabel', labels);

end
