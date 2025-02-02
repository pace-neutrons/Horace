function [xlims, ylims, zlims, ok, mess] = check_plot_limits (lims_type, varargin)
% Check that plot limits have correct format.
%
% If lims_type == 'xy' or 'xyz':
%   >> [lims, ok, mess] = check_plot_limits (lims)
%   >> [lims, ok, mess] = check_plot_limits (lims, xlo, xhi)
%   >> [lims, ok, mess] = check_plot_limits (lims, xlo, xhi, ylo, yhi)
%
% If lims_type == 'xyz' only:
%   >> [lims, ok, mess] = plot_limits_valid (lims, xlo, xhi, ylo, yhi, zlo, zhi)
%
% Input:
% ------
%   lims_type   Limits type: 
%               'xy'    accept up to x-axis and y-axis limits
%               'xyz'   accept up to x-axis, y-axis and z-axis limits
%
%   xlo, xhi    Limits along x-axis:
%               - Must have xlo < xhi
%               - One or both can be infinite (xlo = -Inf, xhi = Inf)
%               - If both are [] on entry, then on exit xlo = -Inf, xhi = Inf
%
%   ylo, yhi    If given: as for xlo, xhi
%
%   zlo, zhi    If given: as for xlo, xhi
%
% Output:
% -------
%   xlims       [xlo, xhi] if valid limits
%               [] if not given or both were empty (indicating 'skip')
%
%   ylims       Same for ylo, yhi
%
%   zlims       Same for zlo, zhi
%
%   ok          True if all limits were valid
%               False otherwise
%
%   mess        Empty character vector '' if ok
%               Error message if not ok


xlims = [];
ylims = [];
zlims = [];

narg = numel(varargin);
if strcmpi(lims_type, 'xy') || strcmpi(lims_type, 'xyz')
    if narg==0 || narg==2 || narg==4 || (strcmpi(lims_type, 'xyz') && narg==6)
        if narg>=2
            [xlims, ok, mess] = check_axis_limits (varargin{1:2}, 'x');
            if ~ok
                return
            end
        end
        if narg>=4
            [ylims, ok, mess] = check_axis_limits (varargin{3:4}, 'y');
            if ~ok
                return
            end
        end
        if narg>=6
            [zlims, ok, mess] = check_axis_limits (varargin{5:6}, 'z');
            if ~ok
                return
            end
        end
    else
        ok = false;
        mess = 'Check the number of plot limits.';
        return
    end
else
    error('HERBERT:graphics:invalid_argument', ...
        'Unrecognised limits type. Please contact the developers.')
end

% OK if got to this point
ok = true;
mess = '';


%-------------------------------------------------------------------------------
function [lims, ok, mess] = check_axis_limits (vlo, vhi, axis_name)
% Check that a pair of limits are valid
%
%   >> [lims, ok, mess] = check_axis_limits (vlo, vhi, axis_name)
%
% Input:
% ------
%   vlo         Lower limit value (scalar numeric)
%   vhi         Upper limit value (scalar numeric)
%   axis_name   Name of axis: 'x', 'y', 'z'
%
% Output:
% -------
%   lims        [vlo, vhi] if vlo < vhi (and neither were NaN)
%               Empty numeric [] if both vlo and vhi were empty numerics
%               (This is used to indicate that no limits were provided)
%
%   ok          True if vlo and vhi were valid
%               False otherwise
%
%   mess        Empty character vector '' if ok
%               Error message if not ok


% Initialise output
lims = [];
ok = false;  % assume the worst
mess = '';

% Perform checks
if ~isnumeric(vlo) || ~isnumeric(vhi)
    mess = ['Plot limits along the ', axis_name, '-axis must both be numeric'];
elseif isempty(vlo) && isempty(vhi)
    lims = [];
    ok = true;
elseif ~isscalar(vlo) || ~isscalar(vhi)
    mess = ['Plot limits along the ', axis_name, '-axis must both be ', ...
        'scalars or both empty'];
elseif isnan(vlo) || isnan(vhi)
    mess = ['Neither plot limit along the', axis_name, '-axis can be a NaN'];
elseif vlo >= vhi
    mess = ['Plot limits along the ', axis_name, '-axis must have ', ...
        axis_name, 'lo < ', axis_name, 'hi'];
else
    lims = [vlo, vhi];
    ok = true;
end
