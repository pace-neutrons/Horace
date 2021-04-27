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
%   >> [cov_proj, cov_spec, cov_hkle] = resolution_plot (...)
%
% Without creating a plot (useful if just want the covariance matrix):
%   >> [cov_proj, cov_spec, cov_hkle] = resolution_plot (..., 'noplot')
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
%                                 of the plot
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
%   'curr'          Overplot on the currently active plot
%
%   'name', name    Overplot on the named figure or figure number of an existing plot
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


% The special case of an sqw object with no pixels, a single header and a single
% detector will be treated as valid. This will have come from the general
% purpose resolution function tool called resolution_plot that plots without a
% dataset.



% Check sqw object
% ----------------
if ~isscalar(w) || dimensions(w)~=2
    error ('Can only plot resolution function for a single two dimensional sqw object')
elseif w.data.pix.num_pixels==0
    error ('No pixels in the sqw object - cannot compute a resolution function')
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
    error('Only one of the plot options ''noplot'', ''current'', and ''name'' can be present')
end

% Get point(s) at which to calculate the resolution covariance matrix
% Points are given in units of the projection axes
if numel(par)==0
    p = w.data.p;
    xp = [0.5*(p{1}(1)+p{1}(end)), 0.5*(p{2}(1)+p{2}(end))];    % mid-points of plot axes
elseif numel(par)==1
    xd = par{1};
    if ~(isnumeric(xd) && size(xd,2)==2 && size(xd,1)>0 && all(isfinite(xd(:))))
        error('Position must be an n x 2 array where n is the number of points at which to plot')
    end
    if flipped_display_axes, xp = xd(:,[2,1]); else, xp = xd; end
else
    error('Check the number of parameters and keyword options')
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
        figure(fig)
    else
        % New plot
        plot(w)
    end
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

% Compute resolution function, and plot unless 'noplot' requested
[xp_ok, ipix] = get_nearest_pixels (w, xp);
[cov_proj, cov_spec, cov_hkle] = resfun_model(w, ipix);
iax_plot = [w.data.pax, iax];
if ~present.noplot
    for i=1:numel(ipix)
        resolution_plot_private (xp_ok(i,:), cov_proj(:,:,i),...
            iax_plot, flipped_display_axes)
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
