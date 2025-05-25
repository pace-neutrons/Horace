function varargout = lc (varargin)
% Change colour scale limits for the current axes on the current figure.
%
% Replot with change of limits:
%   >> lc (clo, chi)    % Sets limits to clo to chi; the limits retained for
%                       % further overplotting
%   Equivalently:
%   >> lc  clo  chi
%
% Change limits to autoscale to encompass all data:
%   >> lc               % Set limits to match the range of the data.
%                       % The limits automatically change to accommodate further
%                       % overplotting
%
% Return current limits (without changing range):
%   >> [clo, chi] = lc
%
% Replot several times with different limits in sequence:
%   (Change limits to first pair [clo(1),chi(1)], then hit <CR> to change to the
%   next pair in then sequence, [clo(2),chi(2)], and so on)
%   >> lc (clo, chi)    % clo and chi are arrays with the same number of
%                       % elements;
%   Equivalently:
%   >> lc  clo  chi
%
%   or, for backwards compatibility:
%   >> lc ([clo1,chi2], [clo2,chi2],...)    % clo1, chi1, clo2, chi2... scalars
%   >> lc ({[clo1,chi2],[clo2,chi2],...})   % equivalent syntax


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
[varargout{1:nargout}] = set_limits ('C', args{:});
