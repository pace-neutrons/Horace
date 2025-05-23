function varargout = lz (varargin)
% Change z-axis limits for the current axes on the current figure. If there is
% only colour data, change that on the assumption that the colour scale
% represents the z data.
%
% Replot with change of limits:
%   >> lz (zlo, zhi)    % Sets limits to zlo to zhi; the limits retained for
%                       % further overplotting
%   Equivalently:
%   >> lz  zlo  zhi
%
% Change limits to autoscale to encompass all data:
%   >> lz               % Set limits to match the range of the data.
%                       % The limits automatically change to accommodate further
%                       % overplotting
%
%   The default automatic limit method is to exactly match the range of the data.
%   Automatic limits can be set and the default behaviour altered for all
%   subsequent overplotting to the current figure with one of the options:
%
%   >> lz ('tight')     % [Default] Fit the limits to tightly match the full data range
%   >> lz ('tickaligned') % Align to tick marks while still encompassing the full data range
%   >> lz ('padded')    % Add a thin margin of padding each side of the full data range
%                       %    [NOTE: 'padded' has the same effect as 'tickaligned' for Matlab
%                       %     earlier than R2021a, as 'padded' is not supported]
%   >> lz ('rounded')   % Equivalent syntax to 'padded'
%
%   Equivalently:
%   >> lz  tight        % limit method set without parentheses
%   >> lz  tickaligned
%       :
%
% Return current limits (without changing range):
%   >> [zlo, zhi] = lz
%
% Replot several times with different limits in sequence:
%   (Change limits to first pair [zlo(1),zhi(1)], then hit <CR> to change to the
%   next pair in then sequence, [zlo(2),zhi(2)], and so on)
%   >> lz (zlo, zhi)    % zlo and zhi are arrays with the same number of
%                       % elements;
%   Equivalently:
%   >> lz  zlo  zhi
%
%   or, for backwards compatibility:
%   >> lz ([zlo1,zhi2], [zlo2,zhi2],...)    % zlo1, zhi1, zlo2, zhi2... scalars
%   >> lz ({[zlo1,zhi2],[zlo2,zhi2],...})   % equivalent syntax
%
%
% This function closely mimics the matlab intrinsic function zlim
%
% See also zlim


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
[varargout{1:nargout}] = set_limits ('Z', args{:});
