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
%   >> wdisp=spaghetti_plot(...)                   % outputs the cuts as an IX_dataset_2d array
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
%   wdisp           Array of IX_dataset_2d containing the cuts - e.g. previous generated
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
% Output:
% -------
%   wdisp       Array of IX_dataset_2d containing the cuts, one per q-segment.
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
% $revision$ ($date$)

% TODO: Make it work for dnd objects (no arbitrary projections...)
% TODO: Make smoothing work for IX_dataset objects

% Set defaults
% ------------
arglist = struct('qbin',0.05,'qwidth',0.1,'ebin',[],'labels','','noplot',false,...
                 'smooth',0,'smooth_shape','hat','logscale',false,'clim',[NaN NaN]);
flags = {'noplot','logscale'};

% Parse the arguments:
% --------------------
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if numel(args)~=2
    if length(args{1})>1 && strcmp(class(args{1}(1)),'IX_dataset_2d')
        plot_dispersion(args{1},opt);
        return
    else
        error('Check number of arguments')
    end
end

if size(args{1},2)~=3 || size(args{1},1)<2
    error('Check argument giving list of reciprocal lattice points')
end

try
    sqwfile = exist(args{2},'file');
catch
    sqwfile = 0;
end

if strcmp(class(args{2}),'sqw')
    hd = struct(args{2}).data;
elseif sqwfile
    hd = head_sqw(args{2});
elseif length(args{2})>1 && strcmp(class(args{2}(1)),'IX_dataset_2d')
    plot_dispersion(args{2},opt);
    return
else
    error('Check argument giving data source. Must be an sqw object or sqw file')
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
if ~present.labels
    labels=make_labels(rlp);
else
    if ~isempty(opt.labels) && iscellstr(opt.labels) && numel(opt.labels)==size(rlp,1)
        labels=opt.labels;
    else
        error('Check number of user-supplied labels and that they form a cell array of strings')
    end
end


% Some initialising
%------------------
b = bmatrix(hd.alatt,hd.angdeg);
nseg=size(rlp,1)-1;
proj.type='rrr';
qinc=0;


% Checks if all the rlp's are in a plane
%---------------------------------------
if nseg>1
    u1rlp = rlp(1,:)-rlp(2,:);
    u1crt = (b*u1rlp')';
    u2rlp = rlp(2,:)-rlp(3,:);
    u2crt = (b*u2rlp')';
    u2crt0 = cross(u1crt,u2crt);
    % By definition, 2 lines define a plane, so we only check the case of nseg>2
    if nseg>2
        for i=3:nseg
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
    disp(sprintf('spaghetti_plot: rlp found to lie in the plane perpendicular to (%g %g %g)',inv(b)*u2crt0'));
end


% Loop over rlp, determines the projections and make the cuts
%------------------------------------------------------------
xrlp = 0;
for i=1:nseg
    % Choose u1 along the user desired q-direction 
    u1rlp = rlp(i,:)-rlp(i+1,:);
    u1crt = (b*u1rlp')';
    u1crt = u1crt./norm(u1crt);
    % Choose u2 to be either perpendicular to the plane of all the rlp (previous determined)
    %   or the plane defined by u1 and c* or, if u1||c*, the plane defined by u1 and a*.
    if isempty(u2crt0)
        u2crt = cross(u1crt,b*[0;0;1]./norm(b*[0;0;1]));
        if sum(u2crt)==0
            u2crt = cross(u1crt,b*[1;0;0]./norm(b*[1;0;0]));
        end
    else 
        u2crt = u2crt0./norm(u2crt0);
    end
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
    u20= dot(b*rlp(i,:)',u2crt)/ulen(2);
    u30= dot(b*rlp(i,:)',u3crt)/ulen(3);
    u1 = [dot(b*rlp(i,:)',u1crt)/ulen(1), u1bin, dot(b*rlp(i+1,:)',u1crt)/ulen(1)];
    u2 = [u20-u2bin,u20+u2bin];
    u3 = [u30-u3bin,u30+u3bin];
    % cuts requires monotonically increasing bins
    if (u1(3)-u1(1))<0
        u1 = fliplr(u1);
        flipit = true;
    else
        flipit = false;
    end
    % Make cut, set x-axis as incremental q (in 1/Ang), and update its running value
    qcut = cut_sqw(sqw,proj,u1,u2,u3,ebin,'-nopix')
    if opt.smooth>0
        qcut = smooth(qcut,opt.smooth,opt.smooth_shape);
    end
    if nargout>1
        u1v = u1(1):u1(2):u1(3)
        for j=1:numel(u1v)-1
            varargout{2}{i}(j) = cut(qcut,u1v(j:j+1),[]);
        end
    end
    % Need to convert to IX_dataset_2d in order flip the data, and adjust bin boundaries
    wdisp(i) = IX_dataset_2d(qcut);
    if flipit
        wdisp(i).signal = flipud(wdisp(i).signal);
        wdisp(i).error  = flipud(wdisp(i).error);
    end
    % Modifies the first and last bins of each segment so there is no overlap between segments
    wdisp(i).x(1)   = wdisp(i).x(1)  +u1bin/2;
    wdisp(i).x(end) = wdisp(i).x(end)-u1bin/2;
    % Converts the x-axis from r.l.u. along the segment q-direction to incremental |q| in 1/Ang
    wdisp(i).x = qinc + (wdisp(i).x-wdisp(i).x(1)).*ulen(1);
    qinc = wdisp(i).x(end);
    % Update current segment length for labelling position.
    wdisp(i).x_axis = IX_axis('Momentum',[char(197),'^{-1}']);
    wdisp(i).y_axis = IX_axis('Energy','meV');
    wdisp(i).title{4} = sprintf('Segment from (%f %f %f) to (%f %f %f)',rlp(i,:),rlp(i+1,:));
    wdisp(i).x_axis.code = labels{i};
end

% Stuff unused fields in the IX_dataset_2D with information required for reploting from the array
if numel(opt.qwidth)==1
    intstr=sprintf(['integrated over %f ',char(197),'^{-1} in perpendicular q-directions'],opt.qwidth(1));
else
    intstr=sprintf(['integrated over %f ',char(197),'^{-1} in qv and %f ',char(197),'^{-1} in qw'],opt.qwidth);
end
wdisp(1).y_axis.code = sprintf(['q bin size approximately %f ',char(197),'^{-1}'],opt.qbin);
wdisp(1).s_axis.code = intstr;


% Output arrays if desired
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
function plot_dispersion(wdisp,opt)
% Plots the dispersion in the structure wdisp
    wdisp(1).title = {wdisp(1).title{1},wdisp(1).s_axis.code,wdisp(1).y_axis.code};
    % This might not be the best way to do this but the 2D dataset should(!) hopefully not
    %   take up too much memory to make a copy of wdisp...
    if opt.logscale
        for i=1:length(wdisp)
            wdisp(i).signal = log10(wdisp(i).signal);
        end
    end
    plot(wdisp);
    hold on;
    xrlp = 0;
    for i=1:length(wdisp);
        xrlp(i+1) = wdisp(i).x(end);
        plot([1 1]*xrlp(i+1),get(gca,'YLim'),'-k');
        labels{i} = wdisp(i).x_axis.code;
    end
    hold off;
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
        hc=colorbar; 
        % Old style workaround - does not work on Matlab 2015 onwards
        if verLessThan('matlab','8.6')
            yd=10.^get(get(hc,'Children'),'YData');
            set(hc,'YScale','log');
            set(hc,'YLim',yd);
            set(get(hc,'Children'),'YData',yd);
        % New style workaround - only works on Matlab 2015 onwards!
        else
            set(hc,'TicksMode','manual');
            majorticks = ceil(log10(opt.clim(1))):floor(log10(opt.clim(2)));
            ntick=(numel(majorticks)-1)*9;
            unitbefore = 10^majorticks(1)/10;
            tickstart = ceil(opt.clim(1)*unitbefore)/unitbefore;
            ticksbefore = tickstart:unitbefore:unitbefore*9;
            unitafter = 10^majorticks(end);
            tickend = floor(opt.clim(2)*unitafter)/unitafter;
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
function labels=make_labels(rlp)
% Make labels for graphs from list of r.l.p
nrlp=size(rlp,1);
labels=cell(1,nrlp);
for i=1:nrlp
    labels{i}=['[',str_compress(num2str(rlp(i,:)),','),']'];
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

