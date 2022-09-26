function varargout = resolution_plot (w, varargin)
% Plot resolution function at one or more points on a 2D sqw object
%
% New resolution plot:
%   >> resolution_plot (w)                  % Compute at centre of the sqw object
%   >> resolution_plot (w, xres)            % Compute at xres on the display axes
%   >> resolution_plot (..., 'axis', ax)    % Draw intersection along integration axis
%
% On current plot, or named or numbered existing plot (e.g. previous plot of w itself):
%   >> resolution_plot (..., 'curr')        % on currently active plot
%   >> resolution_plot (..., 'name', name)  % on named plot
%
% Return the covariance matrix in various coordinate frames:
%   >> [cov_proj, cov_spec, cov_hkle, kept] = resolution_plot (...)
%
% Without creating a plot (useful if just want the covariance matrix):
%   >> [cov_proj, cov_spec, cov_hkle, kept] = resolution_plot (..., 'noplot')
%
%
% Input:
% ------
%   w       Two dimensional sqw object (Q-Q plot or Q-E plot)
%
%   xres    Coordinates along display axes at which to compute resolution
%          function. The resolution function is plotted for the pixel closest
%          to the specified position.
%
%           - Single point: xres = [x1, x2], where x1 is the position along
%             the x-axis of the plot, x2 is the position along the y-axis
%
%           - Multiple points: xres is an array size [npnt, 2], one row per point
%           Computed for the pixel closest to this point
%
%           Default if not given: Computed for the pixel closest to the centre
%                                 of the plot in
%
% Intersection axis option:
%   ax      Option to choose which of the two integration axes for which the
%          intersection of the resolution function in the plot plane will be
%          drawn at a non-zero value along that axis. Options are:
%           If Q-E plot:
%               '+'     cyclic permutation of momentum axes
%                      E.G. if plot axes are 2 and 4 (i.e. 2nd projection
%                         axis and energy) then intersection axis is set to 3
%                      E.G. if plot axes are 3 and 4, intersection axis is set to 1
%               '-'     anti-cyclic permutation of axes
%                      E.G. for the two cases above, the intersection axis is set
%                       to 1 and 3 respectively
%               iax     Numerical index into projection axes i.e. 1,2 or 3, but
%                      excluding the momentum plot axis
%               'none'  No axis
%
%               Default: '+'
%
%           If Q-Q plot:
%               'q'     The remaining momentum axis
%               'e'     The energy axis
%               'none'  No axis
%
%               Default: 'e'
%
% Plot options:
%   'curr'          Overplot on the currently active plot
%
%   'name', name    Overplot on the existing figure with the given name,
%                   figure number or figure handle
%
%
% Output:
% -------
%   cov_proj    Covariance matrix for wavevector-energy in projection axes
%               Array size [4,4,npnt] where npnt is the number of points at
%              which the resolution function was requested.
%
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes
%              i.e. x || ki, z vertically upwards, y perpendicular to z and x.
%               Array size [4,4,npnt] where npnt is the number of points at
%              which the resolution function was requested.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy
%               Array size [4,4,npnt] where npnt is the number of points at
%              which the resolution function was requested.
%
%   kept        Logical column vector with length equal to the number of
%              points given by input argument xres, where elements =1 for
%              points in bins with contributing pixels, and =0 for points
%              in empty bins or outside the range of the data.


% The special case of an sqw object with no pixels, a single header and a single
% detector will be treated as valid. This will have come from the general
% purpose resolution function tool called resolution_plot that plots without a
% dataset.



% Check sqw object
% ----------------
if ~isscalar(w) || dimensions(w)~=2
    error('HORACE:resolution_plot:invalid_argument',...
        'Can only plot resolution function for a single two dimensional sqw object')
elseif w.pix.num_pixels==0
    error('HORACE:resolution_plot:invalid_argument',...
        'No pixels in the sqw object - cannot compute a resolution function')
end

% Determine if display axes are flipped
if w.data.dax(2)==1
    flipped_display_axes = true;
else
    flipped_display_axes = false;
end


% Check other input arguments and get defaults where necessary
% ------------------------------------------------------------
key = struct ('axis','','noplot',false,'current',false,'name',[]);
flags = {'noplot','current'};
opts.flags_noneg = true;
opts.flags_noval = true;
[par,key,present] = parse_arguments (varargin, key, flags, opts);
present_logical = cell2mat(struct2cell(present));
if sum(present_logical(2:end))>1
    error('HORACE:resolution_plot:invalid_argument',...
        'Only one of the plot options ''noplot'', ''current'', and ''name'' can be present')
end

% Get point(s) at which to calculate the resolution covariance matrix
% Points are given in units of the projection axes
if numel(par)==0
    p = w.data.p;
    xp = [0.5*(p{1}(1)+p{1}(end)), 0.5*(p{2}(1)+p{2}(end))];    % mid-points of plot axes
elseif numel(par)==1
    xd = par{1};
    if ~(isnumeric(xd) && size(xd,2)==2 && size(xd,1)>0 && all(isfinite(xd(:))))
        error('HORACE:resolution_plot:invalid_argument',...
            'Position must be an n x 2 array where n is the number of points at which to plot')
    end
    if flipped_display_axes, xp = xd(:,[2,1]); else, xp = xd; end
else
    error('HORACE:resolution_plot:invalid_argument',...
        'Check the number of parameters and keyword options')
end

% Determine which intersection plotting to perform, if any
if w.data.pax(end)==4
    % Q-E plot
    if (ischar(key.axis) && strcmpi(key.axis,'+')) || isempty(key.axis)
        iax = mod(w.data.pax(1),3) + 1;
    elseif ischar(key.axis) && strcmpi(key.axis,'-')
        iax = mod(w.data.pax(1)+1,3) + 1;
    elseif isnumeric(key.axis) && isscalar(key.axis) && any(w.data.iax==key.axis)
        iax = key.axis;
    elseif ischar(key.axis) && strncmpi(key.axis,'none',numel(key.axis))
        iax = [];
    else
        error('HORACE:resolution_plot:invalid_argument',...
            ['Intersection axis must be a permutation ''+'' or ''-'',',...
            ' or one of the integration axes: ',num2str(w.data.iax)])
    end
else
    % Q-Q plot
    if ischar(key.axis) && strcmpi(key.axis,'q')
        iax = w.data.iax(1);     % the remaining q axis
    elseif (ischar(key.axis) && strcmpi(key.axis,'e')) || isempty(key.axis)
        iax = w.data.iax(2);     % the energy axis
    elseif isnumeric(key.axis) && isscalar(key.axis) && any(w.data.iax==key.axis)
        iax = key.axis;
    elseif ischar(key.axis) && strncmpi(key.axis,'none',numel(key.axis))
        iax = [];
    else
        error('HORACE:resolution_plot:invalid_argument',...
            ['Intersection axis must be ''q'', ''e'',',...
            ' or one of the integration axes: ',num2str(w.data.iax)])
    end
end

% Determine plot window target

if ~present.noplot  % plotting is required
    if present.current || present.name
        % Over-plotting (current plot, or named plot)
        opt.newplot = false;
        if present.current
            opt.over_curr = true;
            [~,ok,mess,~,fig] = genie_figure_parse_plot_args(opt);
        elseif present.name
            opt.over_curr = false;
            [~,ok,mess,~,fig] = genie_figure_parse_plot_args(opt, 'name', key.name);
        end
        if ~ok
            error(mess);
        end
        figure(fig);
    else
        % New plot
        plot(w);
    end
end


% Plot resolution function
% ------------------------
% Determine the instrument
[inst, all_inst] = get_inst_class(w);
if isempty(inst)
    if all_inst
        error('HORACE:resolution_plot:invalid_argument',...
            'The instrument type is not the same for all contributing raw data files')
    else
        error('HORACE:resolution_plot:invalid_argument',...
            'The instrument has not been defined for all contributing raw data files')
    end
end
if strcmp(inst,'IX_inst_DGfermi')
    resfun_model = @tobyfit_DGfermi_resfun_covariance;
elseif strcmp(inst,'IX_inst_DGdisk')
    resfun_model = @tobyfit_DGdisk_resfun_covariance;
else
    error('HORACE:resolution_plot:invalid_argument',...
        'No resolution function model implemented for this instrument')
end

% Compute resolution function, and plot unless 'noplot' requested
[kept, ipix] = get_nearest_pixels (w, xp);
if numel(ipix)>0
    [cov_proj, cov_spec, cov_hkle] = resfun_model(w, ipix);
    xp_kept = xp(kept,:);
    iax_plot = [w.data.pax, iax];
    if ~present.noplot
        for i=1:numel(ipix)
            resolution_plot_private (xp_kept(i,:), cov_proj(:,:,i),...
                iax_plot, flipped_display_axes)
        end
    end
else
    if ~present.noplot
        error('HORACE:resolution_plot:invalid_argument',...
            'Resolution ellipsoid(s) all lie outside bins with data')
    else
        cov_proj = zeros(4,4,0);
        cov_spec = zeros(4,4,0);
        cov_hkle = zeros(4,4,0);
    end
end


% Return covariance matrix, if requested
% --------------------------------------
if nargout>=1
    varargout{1} = cov_proj;
end
if nargout>=2
    varargout{2} = cov_spec;
end
if nargout>=3
    varargout{3} = cov_hkle;
end
if nargout>=4
    varargout{4} = kept;
end


%========================================================================================
function resolution_plot_private (x0,C,iax,flip)
% Plot resolution function on 2D axes
%
%   >> resolution_plot_private (x0,C,iax,flip,fig,newplot)
%
% Input:
% ------
%   x0      Origin of resolution function, [x1,x2] for axes iax(1) and iax(2)
%
%   C       Covariance matrix (4x4) in qx,qy,qz,en (units can be Angstrom^-1
%          or whatever the projection axes units are)
%
%   iax     Indices of axes to plot (all unique, in range 1 to 4)
%           If length 2, these give the axes of the plot plane into C
%           If length 3, then the third axis is one for which an
%          ellipse section is drawn at a positive value along that axis
%
%   flip    If true, flip the plot axes; if false, not
%           For plotting if display axes are reversed from plot axes.


% Original author: T.G.Perring


% Check input arguments
if ~(isnumeric(x0) && numel(x0)==2 && all(isfinite(x0)))
    error('Centre must be a numeric vector length 2')
end

if ~(isnumeric(C) && isequal(size(C),[4,4]))
    error('Covariance matrix has wrong size')
end

if ~(isnumeric(iax) && (numel(iax)==2 || numel(iax)==3) &&...
        numel(unique(iax))==numel(iax) && all(iax>=1) && all(iax)<=4)
    error('Check axes indicies')
end

% Plot parameters
frac = 0.5;     % fraction of maximum at which to draw contours

val = 2*log(1/frac);

% Get envelope and intersection(s)
% - Envelope
C2 = C(iax(1:2),iax(1:2));    % pick out the covariance elements for the plot axes
[x1e,x2e] = ellipse (C2(1,1), C2(1,2), C2(2,2), val);  % envelope

% - Intersection with x1-x2 plane for x3=0 and x3>0
if numel(iax)==3
    C3 = C(iax,iax);
    m = inv(C3);
    c = inv(m(1:2,1:2));
    % Intersection with x3=0
    [x1c_0,x2c_0] = ellipse (c(1,1), c(1,2), c(2,2), val);
    % Intersection with x3>0
    x3max = sqrt(val*C3(3,3));   % maximum value of x3
    x3 = round_mantissa(0.667*x3max);
    dx1 = x3*C3(1,3)/C3(3,3);
    dx2 = x3*C3(2,3)/C3(3,3);
    [x1c_pos,x2c_pos] = ellipse (c(1,1), c(1,2), c(2,2), val-x3^2/C3(3,3));
end

% Perform plot
% ------------
hold on

lwidth = aline;
lcol = acolor;
if iscell(lcol), lcol=lcol{1}; end    % may have more than one color set
if ~flip
    plot(x1e+x0(1),x2e+x0(2),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    if numel(iax)==3
        plot(x1c_0+x0(1),x2c_0+x0(2),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
        plot(x1c_pos+x0(1)+dx1,x2c_pos+x0(2)+dx2,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
else
    plot(x2e+x0(2),x1e+x0(1),'Color',lcol,'LineStyle','-','LineWidth',lwidth);
    hold on
    if numel(iax)==3
        plot(x2c_0+x0(2),x1c_0+x0(1),'Color',lcol,'LineStyle','--','LineWidth',lwidth);
        plot(x2c_pos+x0(2)+dx2,x1c_pos+x0(1)+dx1,'Color',lcol,'LineStyle','--','LineWidth',lwidth);
    end
end

hold off


%========================================================================================
function r=round_mantissa(x)
% Round a positive number to the nearest number with form n*10^m where n, m are integer
xlog = log10(x);
r = round(10^mod(xlog,1))*10^floor(xlog);


%========================================================================================
function [x1,x2] = ellipse (c11,c12,c22,A)
% Get a set of points that lie on the ellipse
%   [x1 x2]*Inv([c11 c12; c12 c22])*[x1; x2] = A  (A>0)

npnt = 500;     % number of points on the ellipse

% Get the orientation of the ellipsoid: angle theta to a minor axis x1'
theta = 0.5*atan2(-2*c12, c22-c11);
c = cos(theta);
s = sin(theta);

% Get the lengths of the principal axes along x1', x2'
cc = sqrt((c22-c11)^2+4*c12^2);
c1 = sqrt(A*((c22+c11)-cc)/2);
c2 = sqrt(A*((c22+c11)+cc)/2);

% Coordinate of points in x1',x2'
ang=linspace(0,2*pi,npnt);
x1prime = c1*cos(ang);
x2prime = c2*sin(ang);

% Transform to input coordinate frame
x1 = c*x1prime - s*x2prime;
x2 = s*x1prime + c*x2prime;
