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
    error('No resolution fuinction model implemented for this instrument')
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
