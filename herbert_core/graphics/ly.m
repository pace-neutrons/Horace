function varargout = ly (varargin)
% Change y-axis limits for the current axes on the current figure.
%
% Replot with change of limits:
%   >> ly (ylo, yhi)    % Sets limits to ylo to yhi; the limits retained for
%                       % further overplotting
%   Equivalently:
%   >> ly  ylo  yhi
%
% Change limits to autoscale to encompass all data:
%   >> ly               % Set limits to match the range of the data.
%                       % The limits automatically change to accommodate further
%                       % overplotting
%
%   The default automatic limit method is to exactly match the range of the data.
%   Automatic limits can be set and the default behaviour altered for all
%   subsequent overplotting to the current figure with one of the options:
%
%   >> ly ('tight')     % [Default] Fit the limits to tightly match the full data range
%   >> ly ('tickaligned') % Align to tick marks while still encompassing the full data range
%   >> ly ('padded')    % Add a thin margin of padding each side of the full data range
%                       %    [NOTE: 'padded' has the same effect as 'tickaligned' for Matlab
%                       %     earlier than R2021a, as 'padded' is not supported]
%   >> ly ('rounded')   % Equivalent syntax to 'padded'
%
%   Equivalently:
%   >> ly  tight        % limit method set without parentheses
%   >> ly  tickaligned
%       :
%
% Return current limits (without changing range):
%   >> [ylo, yhi] = ly
%
% Replot several times with different limits in sequence:
%   (Change limits to first pair [ylo(1),yhi(1)], then hit <CR> to change to the
%   next pair in then sequence, [ylo(2),yhi(2)], and so on)
%   >> ly (ylo, yhi)    % ylo and yhi are arrays with the same number of
%                       % elements;
%   Equivalently:
%   >> ly  ylo  yhi
%
%   or, for backwards compatibility:
%   >> ly ([ylo1,yhi2], [ylo2,yhi2],...)    % ylo1, yhi1, xlo2, yhi2... scalars
%   >> ly ({[ylo1,yhi2],[ylo2,yhi2],...})   % equivalent syntax
%
%
% This function closely mimics the matlab intrinsic function ylim
%
% See also ylim


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
[varargout{1:nargout}] = set_limits ('Y', args{:});
