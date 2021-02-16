function varargout = resolution_plot (w, varargin)
% Plot resolution function
%
% New resolution plot:
%   >> resolution_plot (w)                  % Compute at centre of the sqw object
%   >> resolution_plot (w, x0)              % Compute at x0 along teh display axes
%   >> resolution_plot (..., 'axis', ax)    % Draw intersection along integration axis
%
% On current existing resolution plot:
%   >> resolution_plot (..., 'over')
%
% On current plot, or named or numbered existing plot (e.g. previous plot of w itself)
%   >> resolution_plot (..., 'curr')
%   >> resolution_plot (..., 'name', name)
%   >> resolution_plot (..., 'fig', fh)  -- where fh is the handle of an
%                                          existing figure to use for plotting
%
%
% Input:
% ------
%   w       Two dimensional sqw object
%
%   x0      Coordinates along display axes at which to compute resolution
%          function (row vector).
%           Computed for the pixel closest to this point
%           In general, can be an n x 2 array, one row per point, for
%          plotting the resolution function at a number of points
%
%           Default: Center of the plot
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
%               '-'     anticyclic permutation of axes
%                      E.G. for the two cases above, the intersection axis is set
%                       to 1 and 3 resepctively
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
%   'over'  If present, then overplot on an existing resolution function plot
%           If one doesn't already exist, create a new resolution function plot
%
%   'curr'  Overplot on the currently active plot
%
%   'name', name    Overplot on the named figure or figure number of an existing plot


% The special case of an sqw object with no pixels, a single header and a single
% detector will be treated as valid


% Check input arguments and get defaults where necessary
% ------------------------------------------------------
% Check sqw object
if ~isscalar(w) || dimensions(w)~=2
    error ('Can only plot resolution function for a single two dimensional sqw object')
end

npixtot = sum(w.data.npix(:));

% Check if special case of single detector, no pixels; otherwise must have pixels
if npixtot==0 && (iscell(w.header) || numel(w.detpar.x2)~=1)
    error('No pixels in the sqw object - cannot compute a resolution function')
end

% Determine if display axes are flipped
if w.data.dax(2)==1
    flip = true;
else
    flip = false;
end

% Centre of plot axes
p = w.data.p;
xp_cent = [0.5*(p{1}(1)+p{1}(end)), 0.5*(p{2}(1)+p{2}(end))];    % mid-points of plot axes
if w.data.pax(end)==4
    qe_plot = true;
else
    qe_plot = false;
end

% Check x0 and axis option
key = struct ('axis','','over',false,'current',false,'name',[],'fig',[]);
flags = {'over','current'};
opts.flags_noneg = true;
opts.flags_noval = true;
[par,key,present] = parse_arguments (varargin, key, flags, opts);
if sum(cell2mat(struct2cell(present(2:end))))>1
    error('Only one of the plot options ''over'', ''current'' and ''name'' can be present')
end

% - Calculation point(s)
if numel(par)==0
    xp = xp_cent;
elseif numel(par)==1 && npixtot>0
    xd = par{1};
    if ~(isnumeric(xd) && size(xd,2)==2 && size(xd,1)>0 && all(isfinite(xd(:))))
        error('Position must be an n x 2 array where n is the number of points at which to plot')
    end
    if flip, xp = xd(:,[2,1]); else, xp = xd; end
elseif numel(par)==1 && npixtot==0
    error('Data contains no data pixels - cannot compute a resolution function')
else
    error('Check the number of parameters and keyword options')
end

% - Additional intersection plotting
if qe_plot
    % Q-energy plot
    if (ischar(key.axis) && strcmpi(key.axis,'+')) || isempty(key.axis)
        iax = mod(w.data.pax(1),3) + 1;
    elseif ischar(key.axis) && strcmpi(key.axis,'-')
        iax = mod(w.data.pax(1)+1,3) + 1;
    elseif isnumeric(key.axis) && isscalar(key.axis) && any(w.data.iax==key.axis)
        iax = key.axis;
    elseif ischar(key.axis) && strncmpi(key.axis,'none',numel(key.axis))
        iax = [];
    else
        error(['Intersection axis must be a permutation ''+'' or ''-'',',...
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
        error(['Intersection axis must be ''q'', ''e'',',...
            ' or one of the integration axes: ',num2str(w.data.iax)])
    end
end

% - Plot target
newplot = false;
if present.over
    fig = [];
elseif present.current
    if ~isempty(findobj(0,'Type','figure'))
        fig = gcf;
    else
        error('No current figure exists - cannot overplot')
    end
elseif present.name
    fig = key.name;
elseif present.fig
    fig = key.fig;
    if ~verLessThan('matlab','8.4') % check its a figure.
        % Do not remeber how to do it in older versions. Should be done if
        % important
        if ~isa(fig,'matlab.ui.Figure')
            error('RESOLUTION_PLOT:invalid_argument',...
                ' The input parameter for "fig" keyword should be a figure handle but it is %s',...
                class(fig));
        end
    end
else
    plot(w) % plot the empty sqw object - sets the correct axes annotations
    colorslider('delete')       % delete the meaningless colorslider
    delete(get(gca,'title'))    % delete unwanted title
    newplot = true;
    fig = [];
end


% Plot resolution function
% ------------------------
% Determine the instrument
[inst, all_inst] = get_inst_class(w);
if isempty(inst)
    if all_inst
        error('The instrument type is not the same for all contributing raw data files')
    else
        error('The instrument has not been defined for all contributing raw data files')
    end
end
if strcmp(inst,'IX_inst_DGfermi')
    resfun_model = @tobyfit_DGfermi_resfun_covariance;
elseif strcmp(inst,'IX_inst_DGdisk')
    resfun_model = @tobyfit_DGdisk_resfun_covariance;
else
    error('No resolution function model implemented for this instrument')
end

iax_plot = [w.data.pax, iax];
if npixtot==0
    % Special case of no data, one header, one detector
    covariance_matrix = resfun_model(w);
    resolution_plot_private ([0,0], covariance_matrix, iax_plot, false)
else
    [xp_ok, ipix] = get_nearest_pixels (w, xp);
    covariance_matrix = resfun_model(w, ipix);
    for i=1:numel(ipix)
        resolution_plot_private (xp_ok(i,:), covariance_matrix(:,:,i),...
            iax_plot, flip)
    end
end

% If newplot, then rescale limits
if newplot
    lx('round')
    ly('round')
end


% Return covariance matrix, if requested
% --------------------------------------
if nargout==1
    varargout{1} = covariance_matrix;
end

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
%   iax     Indicies of axes to plot (all unique, in range 1 to 4)
%           If length 2, these give the axes of the plot plane into C
%           If length 3, then the third axis is one for which an
%          ellipse section is drawn at a positive value along that axis
%
%   flip    If true, flip the plot axes; if false, not
%           For plotting if display axes are reversed from plot axes.


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


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

