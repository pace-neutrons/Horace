function varargout=spaghetti_plot(varargin)
% Plots the data in an sqw file or object along a path in reciprocal space
%
%   >> spaghetti_plot(rlp,data_source)
%   >> spaghetti_plot(wdisp)
%
%   >> spaghetti_plot(...,'labels',{'G','X',...})  % customised labels
%   >> spaghetti_plot(...,'smooth',1)              % smooth data with this width
%   >> spaghetti_plot(...,'smooth_shape','hat')    % smooth data with this shape
%   >> spaghetti_plot(...,'qbin',qb)               % specify q bin size in 1/Ang
%   >> spaghetti_plot(...,'qwidth',qi)             % specify q integration width in 1/Ang
%   >> spaghetti_plot(...,'ebin',[elo estp ehi])   % specify energy bin in meV
%   >> spaghetti_plot(...,'logscale')              % plots intensity in log10 scale
%   >> spaghetti_plot(...,'clim',[cmin cmax])      % sets the colorscale (needed for logscale)
%
%   >> wdisp=spaghetti_plot(...)                   % outputs the cuts as a d2d array
%   >> wdisp=spaghetti_plot(...,'noplot')          % outputs arrays without plotting
%
%   >> [wdisp,cuts]=spaghetti_plot(...)            % generates a set of 1D cuts
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
% Output:
% -------
%   wdisp       Array of d2d objects containing the cuts, one per q-segment.
%
%   cuts        Array of d1d objects of energy cuts along the hkl-lines
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
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

% TODO: Make it work for dnd objects (no arbitrary projections...)

% Set defaults
% ------------
arglist = struct('qbin',0.05,'qwidth',0.1,'ebin',[],'labels','','noplot',false,...
    'smooth',0,'smooth_shape','hat','logscale',false,'clim',[NaN NaN],...
    'cuts_plot_size',[]);
flags = {'noplot','logscale'};

% Parse the arguments:
% --------------------
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if numel(args)~=2
    if length(args{1})>1 && isa((args{1}(1)),'d2d')
        plot_dispersion(args{1},opt);
        return
    else
        error('SPAGHETTI_PLOT:invalid_arguments',...
            'Invalid number of arguments')
    end
end

if size(args{1},2)~=3 || size(args{1},1)<2
    error('SPAGHETTI_PLOT:invalid_arguments',...
        'It should be at least 2 rlp arranged in array [Nx3] (N>=2) but size of the rlp array is: [%d,%d];',...
        size(args{1}))
end
if present.cuts_plot_size
    if size(args{1},1)-1 ~= numel(opt.cuts_plot_size)
        error('SPAGHETTI_PLOT:invalid_arguments',...
            [' the size of the cut_plot_dist array should be one less than the number of rlp points.'...
            ' In fact the number of rlp is %d and the number of distances is %d'],...
            size(args{1},1),numel(opt.cuts_plot_size));
    else
        if any(opt.cuts_plot_size<=0)
            invalid = opt.cuts_plot_size<=0;
            error('SPAGHETTI_PLOT:invalid_arguments',...
                'the plot sizes should be positive numbers but some of them are: %g; %g; %g; %g; %g',...
                opt.cuts_plot_size(invalid));
        end
    end
end

try
    sqwfile = exist(args{2},'file');
catch
    sqwfile = 0;
end

if isa(args{2},'sqw')
    header = struct(args{2}).data;
elseif sqwfile
    header = head_sqw(args{2});
elseif length(args{2})>1 && isa(args{2}(1),'d2d')
    plot_dispersion(args{2},opt);
    return;
else
    error('SPAGHETTI_PLOT:invalid_arguments',...
        'Check argument giving data source. Must be an sqw object or sqw file')
end

qbin = opt.qbin;
qwidth = opt.qwidth;
ebin = opt.ebin;
rlp = args{1};
sqw = args{2};

if numel(qwidth)==1
    qwidth = [1 1]*qwidth;
end


% Make labels
% ------------
if present.labels && (isempty(opt.labels) || ~iscellstr(opt.labels) || numel(opt.labels)~=size(rlp,1))
    error('SPAGHETTI_PLOT:invalid_arguments',...
        'Check number of user-supplied labels and that they form a cell array of strings');
end


% Some initialising
%------------------
b = bmatrix(header.alatt,header.angdeg);
nseg=size(rlp,1)-1;
proj.type='rrr';


% Checks if all the rlp's are in a plane
%---------------------------------------
if nseg>1
    u1rlp = rlp(1,:)-rlp(2,:);
    u1crt = (b*u1rlp')';
    u2rlp = rlp(2,:)-rlp(3,:);
    u2crt = (b*u2rlp')';
    u2crt0 = cross(u1crt,u2crt);
    % Checks if rlp's are collinear.
    j=3;
    while abs(sum(u2crt0))<min(opt.qbin)/100 && j<=nseg
        u2rlp = rlp(j,:)-rlp(j+1,:);
        u2crt = (b*u2rlp')';
        u2crt0 = cross(u1crt,u2crt);
        j=j+1;
    end
    % By definition, 2 lines define a plane, so we only check the case of nseg>2
    if nseg>2
        for i=j:nseg
            u2rlp = rlp(i,:)-rlp(i+1,:);
            u2crt = (b*u2rlp')';
            norve = cross(u1crt,u2crt);
            if abs(sum(cross(norve,u2crt0)))>1e-5
                % Normal vectors are not parallel. Point not in plane
                u2crt0 = [];
                break;
            end
        end
    end
else
    u2crt0 = [];
end
if ~isempty(u2crt0)
    fprintf('spaghetti_plot: rlp found to lie in the plane perpendicular to (%g %g %g)\n',inv(b)*u2crt0');
end


% Loop over rlp, determines the projections and make the cuts
%------------------------------------------------------------
xrlp = 0;
wdisp = repmat(d2d,1,nseg);
for i=1:nseg
    % Choose u1 along the user desired q-direction
    u1rlp = rlp(i+1,:)-rlp(i,:);
    u1crt = (b*u1rlp')';
    u1crt = u1crt./norm(u1crt);
    % Choose u2 to be either perpendicular to the plane of all the rlp (previous determined)
    %   or the plane defined by u1 and c* or, if u1||c*, the plane defined by u1 and a*.
    if isempty(u2crt0)
        u2crt = cross(u1crt,b*[0;0;1]./norm(b*[0;0;1]));
        if sum(abs(u2crt))<min(opt.qbin)/100
            u2crt = cross(u1crt,b*[1;0;0]./norm(b*[1;0;0]));
        end
    else
        u2crt = u2crt0./norm(u2crt0);
    end
    u2crt = u2crt ./ norm(u2crt);
    % Sets the correct normalisation for u1,u2,u3 (u3 perp to u1 x u2)
    u1rlp = (inv(b)*u1crt')';
    u2rlp = (inv(b)*u2crt')';
    u3crt = cross(u1crt,u2crt);
    u3rlp = (inv(b)*u3crt')';
    ulen = 1./max(abs(inv(ubmatrix(u1rlp,u2rlp,b))));
    u1rlp = u1rlp.*ulen(1);
    u2rlp = u2rlp.*ulen(2);
    u3rlp = u3rlp.*ulen(3);
    proj.u = u1rlp; proj.v = u2rlp;
    % determines the bin size in the desired q-direction in r.l.u.
    u1bin = qbin/ulen(1);
    % determines the integration range over the perpendicular q-directions in r.l.u.
    u2bin = qwidth(1)/ulen(2);
    u3bin = qwidth(2)/ulen(3);
    u20= dot(b*rlp(i,:)',u2crt./norm(u2crt))/ulen(2);
    u30= dot(b*rlp(i,:)',u3crt./norm(u3crt))/ulen(3);
    u1 = [dot(b*rlp(i,:)',u1crt)/ulen(1), u1bin, dot(b*rlp(i+1,:)',u1crt)/ulen(1)];
    u1(2)=(u1(3)-u1(1))/floor((u1(3)-u1(1))/u1(2)); % Radu Coldea on 19/12/2018: adjust qbin size to have an exact integer number of bins between the start and end points 
    u2 = [u20-u2bin,u20+u2bin];
    u3 = [u30-u3bin,u30+u3bin];
    % Make cut, and save to array of d2d
    wdisp(i) = cut_sqw(sqw,proj,u1,u2,u3,ebin,'-nopix');
    if nargout>1
        u1v = u1(1):u1(2):u1(3);
        for j=1:numel(u1v)-1
            varargout{2}{i}(j) = cut(wdisp(i),u1v(j:j+1),[]);
        end
    end
    if present.labels
        titlestr = sprintf('Segment from "%s" (%f %f %f) to "%s" (%f %f %f)',...
            opt.labels{i},rlp(i,:),opt.labels{i+1},rlp(i+1,:));
    else
        titlestr = sprintf('Segment from (%f %f %f) to (%f %f %f)',rlp(i,:),rlp(i+1,:));
    end
    if i>1
        wdisp(i).title = titlestr;
    else
        binstr = sprintf(['q bin size approximately %f ',char(197),'^{-1}'],opt.qbin);
        if numel(opt.qwidth)==1
            wdisp(i).title=sprintf(['integrated over %f ',char(197),...
                '^{-1} in perpendicular q-directions\n%s\n%s'],opt.qwidth(1),binstr,titlestr);
        else
            wdisp(i).title=sprintf(['integrated over %f ',char(197),...
                '^{-1} in qv and %f ',char(197),'^{-1} in qw\n%s\n%s'],opt.qwidth,binstr,titlestr);
        end
    end
end

%-------------------------
if nargout>0
    varargout{1}=wdisp;
end


% Plot dispersion
%----------------
if nargout<1 || (~present.noplot)
    plot_dispersion(wdisp,opt)
end


%========================================================================================================
function plot_dispersion(wdisp_in,opt)
% Plots the dispersion in the structure wdisp
persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('Matlab','8.6');
end
if isempty(opt.cuts_plot_size)
    scale_x_axis = false;
else
    scale_x_axis = true;
end


qinc = 0;
title = wdisp_in(1).title;
lnbrk = strfind(title,sprintf('\n'));
if ~isempty(lnbrk)
    lnbrk = lnbrk(end);
end
wdisp_in(1).title = title(lnbrk+1:end);
%
wdisp = repmat(IX_dataset_2d,1,length(wdisp_in));
for i=1:length(wdisp_in)
    ulen = wdisp_in(i).ulen;
    % Internally use IX_dataset_2d to manipulate the x-axis (flip and adjust bin boundaries)
    if opt.smooth>0
        wdisp(i) = IX_dataset_2d(smooth(wdisp_in(i),opt.smooth,opt.smooth_shape));
    else
        wdisp(i) = IX_dataset_2d(wdisp_in(i));
    end
    % For plotting, change bin edges to bin centres
    bin_centers = 0.5*(wdisp(i).x(1:end-1)+wdisp(i).x(2:end));
    if scale_x_axis
        % scale plot axis according to the scales provided
        min_bc = min(bin_centers);
        size  = max(bin_centers)-min_bc;
        scale = opt.cuts_plot_size(i);
        wdisp(i).x = qinc + (bin_centers-min_bc)*(scale/size);
    else
        % Converts the x-axis from r.l.u. along the segment q-direction to incremental |q| in 1/Ang
        wdisp(i).x = qinc + (bin_centers-bin_centers(1))*ulen(1);
    end
    qinc = wdisp(i).x(end);
    % Update current segment length for labelling position.
    wdisp(i).x_axis = IX_axis('Momentum',[char(197),'^{-1}']);
    wdisp(i).y_axis = IX_axis('Energy','meV');
    % Finds labels in segment title
    brk = strfind(wdisp_in(i).title,sprintf('\n'));
    if ~isempty(brk)
        brk = brk(end);
        wdisp_in(i).title = title(brk+1:end);
    end
    try
        bra = strfind(wdisp_in(i).title,'(');
        ket = strfind(wdisp_in(i).title,')');
        hkls = [sscanf(wdisp_in(i).title(bra(1):ket(1)),'(%f %f %f)');
            sscanf(wdisp_in(i).title(bra(2):ket(2)),'(%f %f %f)')];
        quotes = strfind(wdisp_in(i).title,'"');
        if i>1 && abs(sum(hkls(1:3)-hkl0(1:3)))>0.01
            %warning('(hkl) points for segments %d and %d do not match',i-1,i);
            if isempty(quotes)
                labels{i} = sprintf('[%s]/[%s]',str_compress(num2str(hkl0(4:6)')),str_compress(num2str(hkls(1:3)')));
            else
                labels{i} = sprintf('%s/%s',labels{i},wdisp_in(i).title(quotes(1)+1:quotes(2)-1));
            end
        else
            if isempty(quotes)
                labels{i} = ['[',str_compress(num2str(hkls(1:3)'),','),']'];
            else
                labels{i} = wdisp_in(i).title(quotes(1)+1:quotes(2)-1);
            end
        end
        if isempty(quotes)
            labels{i+1} = ['[',str_compress(num2str(hkls(4:6)'),','),']'];
        else
            labels{i+1} = wdisp_in(i).title(quotes(3)+1:quotes(4)-1);
        end
    catch
        hkldir = wdisp_in(i).u_to_rlu(1:3, 1);
        inthkl = kron(wdisp_in(i).iint', wdisp_in(i).u_to_rlu(:, wdisp_in(i).iax)); 
        hklcen = sum([mean(inthkl(1:3, [1 3]), 2) mean(inthkl(5:7, [2 4]), 2)], 2);
        hkls = [wdisp_in(i).p{1}(1) * hkldir + hklcen; wdisp_in(i).p{1}(end) * hkldir + hklcen];
        labels{i} = ['[',str_compress(num2str(hkls(1:3)'),','),']'];
        labels{i+1} = ['[',str_compress(num2str(hkls(4:6)'),','),']'];
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
wdisp(1).title = title(1:lnbrk);
plot(wdisp);
hold on;
xrlp = zeros(length(wdisp)+1,1);
for i=1:length(wdisp)
    xrlp(i+1) = wdisp(i).x(end);
    plot([1 1]*xrlp(i+1),get(gca,'YLim'),'-k');
end
hold off;
if ~isempty(opt.labels)
    if iscellstr(opt.labels) && numel(opt.labels)==length(wdisp)+1
        labels = opt.labels;
    else
        warning(['Not using user-supplied labels. They are either not a cell array of' ...
            'strings or not enough for all segments']);
    end
end
plot_labels(labels,xrlp);
if sum(isnan(opt.clim))~=2
    if opt.logscale
        clim = log10(opt.clim);
    else
        clim = opt.clim;
    end
    caxis(clim);
    chld = get(gcf,'Children');
    set(findobj(chld,'tag','color_slider_min_value'),'String',num2str(opt.clim(1)));
    set(findobj(chld,'tag','color_slider_max_value'),'String',num2str(opt.clim(2)));
end
if opt.logscale
    if sum(isnan(opt.clim))~=2
        clim = opt.clim;
    else
        clim = 10.^get(gca,'CLim');
        chld = get(gcf,'Children');
        set(findobj(chld,'tag','color_slider_min_value'),'String',num2str(clim(1)));
        set(findobj(chld,'tag','color_slider_max_value'),'String',num2str(clim(2)));
    end
    hc=colorbar;
    % Old style workaround - does not work on Matlab 2015 onwards
    if old_matlab
        yd=10.^get(get(hc,'Children'),'YData');
        set(hc,'YScale','log');
        set(hc,'YLim',yd);
        set(get(hc,'Children'),'YData',yd);
        % New style workaround - only works on Matlab 2015 onwards!
    else
        set(hc,'TicksMode','manual');
        majorticks = ceil(log10(clim(1))):floor(log10(clim(2)));
        ntick=(numel(majorticks)-1)*9;
        unitbefore = 10^majorticks(1)/10;
        tickstart = ceil(clim(1)*unitbefore)/unitbefore;
        ticksbefore = tickstart:unitbefore:unitbefore*9;
        unitafter = 10^majorticks(end);
        tickend = floor(clim(2)*unitafter)/unitafter;
        ticksafter = unitafter:unitafter:tickend;
        ntick = ntick + numel(ticksbefore) + numel(ticksafter);
        minorticks = zeros(1,ntick);
        ticklabels = cell(1,ntick);
        offset = numel(ticksbefore);
        minorticks(1:offset) = ticksbefore;
        for i=0:numel(majorticks)-2
            unit = 10^majorticks(i+1);
            minorticks(i*9+1+offset:(i+1)*9+offset) = [unit:unit:9*unit];
            ticklabels{i*9+1+offset} = num2str(unit);
        end
        if numel(majorticks)<2
            i = offset+1;
        else
            i = (i+1)*9+1+offset;
        end
        minorticks(i:end) = ticksafter;
        ticklabels{i} = num2str(10^majorticks(end));
        set(hc,'Ticks',log10(minorticks));
        set(hc,'TickLabels',ticklabels);
    end
end

%========================================================================================================
function plot_labels(labels,xvals)
% Labels for plots.
%
%   >> plot_labels(labels,ndiv)
%
%   labels      cell array of labels
%   xvals       positions for the labels

set(gca,'XTick',xvals);
set(gca,'XTickLabel',labels);

