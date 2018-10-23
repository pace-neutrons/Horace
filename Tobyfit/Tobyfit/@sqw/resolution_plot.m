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
%
%
% Input:
% ------
%   w       Two dimensional sqw object
%
%   x0      Coordinates along display axes at which to compute resolution
%          function (row vector).
%           Computed for the pixel closest to this point
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
key = struct ('axis','','over',false,'current',false,'name',[]);
flags = {'over','current'};
opts.flags_noneg = true;
opts.flags_noval = true;
[par,key,present] = parse_arguments (varargin, key, flags, opts);
if sum(cell2mat(struct2cell(present(2:end))))>1
    error('Only one of the plot options ''over'', ''current'' and ''name'' can be present')
end

% - Calculation point(s)
if numel(par)==0
    xd = [xp_cent(2), xp_cent(1)];
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
if present.over
    newplot = false;
    fig = [];
elseif present.current
    newplot = false;
    if ~isempty(findobj(0,'Type','figure'))
        fig = gcf;
    else
        error('No current figure exists - cannot overplot')
    end
elseif present.name
    newplot = false;
    fig = key.name;
else
    newplot = true;
    fig = [];
end


% Determine which pixel(s) to use for plotting the resolution function
% ---------------------------------------------------------------------
use_tube = 0;


% Plot resolution function
% ------------------------
iax_plot = [w.data.pax, iax];
if npixtot==0
    % Special case of no data, one header, one detector
    covariance_matrix = tobyfit_DGfermi_res_covariance (w.header, w.detpar,...
        w.data.u_to_rlu, use_tube);
    resolution_plot_private ([0,0], covariance_matrix, iax_plot, fig, newplot)
else
    error('Not yet implemented')
end


% Return covariance matrix, if requested
% --------------------------------------
if nargout==1
    varargout{1} = covariance_matrix;
end
