function varargout = lx (varargin)
% Change x-axis limits for the current axes on the current figure.
%
% Replot with change of limits:
%   >> lx (xlo, xhi)    % Sets limits to xlo to xhi; the limits retained for
%                       % further overplotting
%   Equivalently:
%   >> lx  xlo  xhi
%
% Change limits to autoscale to encompass all data:
%   >> lx               % Set limits to match the range of the data.
%                       % The limits automatically change to accommodate further
%                       % overplotting
%
%   The default automatic limit method is to exactly match the range of the data.
%   Automatic limits can be set and the default behaviour altered for all
%   subsequent overplotting to the current figure withone of the options:
%
%   >> lx ('padded')    % Add a thin margin of padding each side of the full data range
%   >> lx ('rounded')   % Equivalent syntax
%   >> lx ('tickaligned') % Align to tick marks while still encompassing the full data range
%   >> lx ('tight')     % [Default] Fit the limits to tightly match the full data range
%
%   Equivalently:
%   >> lx  padded       % limit method set without parentheses
%   >> lx  rounded
%       :
%
% Return current limits (without changing range):
%   >> [xlo, xhi] = lx
%
% Replot several times with different limits in sequence:
%   (Change limits to first pair [xlo(1),xhi(1)], then hit <CR> to change to the
%   next pair in then sequence, [xlo(2),xhi(2)], and so on)
%   >> lx (xlo, xhi)    % xlo and xhi are arrays with the same number of
%                       % elements;
%   Equivalently:
%   >> lx  xlo  xhi
%
%   or, for backwards compatibility:
%   >> lx ([xlo1,xhi2], [xlo2,xhi2],...)    % xlo1, xhi1, xlo2, xhi2... scalars
%   >> lx ({[xlo1,xhi2],[xlo2,xhi2],...})   % equivalent syntax
%
%
% This function closely mimics the matlab intrinsic function xlim
%
% See also xlim


% Resolve input arguments
if nargin>0 && all(cellfun(@(x)(is_string(x) & ~isempty(x)), varargin))
    % All input arguments are character vectors - the function could have
    % been called with command syntax.
    %
    % The only valid case of command syntax where valid input arguments are not
    % character strings is two arguments giving the lower and upper limits plot
    % limits. It is only this case that needs to have evaluation in the caller
    % workspace performed in order to resolve passed variable names or
    % expressions.
    if nargin==2
        try
            args = {evalin('caller',varargin{1}), evalin('caller',varargin{2})};
        catch
            error('HERBERT:graphics:invalid_argument', ['Check there are ', ...
                'two input arguments giving the lower and upper ranges']);
        end
    else
        args = varargin;
    end
else
    % Must have been function syntax
    args = varargin;
end


% Perform the operation
[varargout{1:nargout}] = set_limits ('X', args{:});
