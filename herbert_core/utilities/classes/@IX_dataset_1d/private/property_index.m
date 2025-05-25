function varargout = property_index (nw, color_cycle, varargin)
% Get the indices into colour, line and marker properties for an array of datasets
%
%   >> [icol, ix1, ix2,...] = property_index (nw, color_cycle, ncol, n1, n2,...)
%
% Input:
% ------
%   nw          Number of datasets.
%
%   color_cycle If 'with': colours cycle in step with other properties.
%               If 'fast': colours go through a full cycle with fixed
%                          property indices before those indices are
%                          incremented by unity.
%
%   ncol        Number of colours
%
%   n1, n2,...  Numbers of property_1, property_2,...
%
% Output:
% -------
%   icol        Row vector length nw of indices of colours
%   ix1, ix2,...Row vectors of indices of properties modulo n1, n2, ...
%
% EXAMPLES
% (1) nw==1, color_cycle=='with', ncol==3, n1==2, n2==3:
%
%   icol: 1  2  3  1  2  3  1  2  3  1  2
%   ix1:  1  2  1  2  1  2  1  2  1  2  1
%   ix2:  1  2  3  1  2  3  1  2  3  1  2 
%
% (2) nw==1, color_cycle=='fast', ncol==3, n1==2, n2==3:
%
%   icol: 1  2  3  1  2  3  1  2  3  1  2
%   ix1:  1  1  1  2  2  2  1  1  1  2  2
%   ix2:  1  1  1  2  2  2  3  3  3  1  1

% Check input arguments
if ~(isnumeric(nw) && isfinite(nw) && rem(nw,1)==0 && nw>=0)
    error('HERBERT:graphics:invalid_argument', ...
        'The number of datasets cannot be negative')
elseif ~is_string(color_cycle) || ~any(strcmp(color_cycle, {'fast', 'with'}))
    error('HERBERT:graphics:invalid_argument', ['''color_cycle must be', ...
        '''fast'' or ''with'''])
elseif numel(varargin)==0
    error('HERBERT:graphics:invalid_argument', 'Must provide number of colors')
elseif ~all(cellfun(@(x)(isnumeric(x) && isfinite(x) && rem(x,1)==0 && x>0), varargin))
    error('HERBERT:graphics:invalid_argument', ['The number of colors any ', ...
        'other properties must be positive integers greater than zero'])
end

% Get number of colours and number of every other property as a row vector, and
% set up the number of output arguments
ncol = varargin{1};
n = cat(2,varargin{2:end});
varargout = cell(1, max(1,numel(varargin)));

% Compute
ixmod = @(ix,n)(mod(ix-1, n) + 1);  % modulus of index ix modulus base n

switch color_cycle
    case 'with'
        % Colours and property cycle in step. For exmaple, if nw==11, ncol==3
        % we expect:
        %   dataset index    1  2  3  4  5  6  7  8  9  10  11
        %   colour index     1  2  3  1  2  3  1  2  3   1   2
        %   property index   1  2  3  1  2  3  1  2  3   1   2
        ix = 1:nw;
        varargout{1} = ixmod(ix, ncol);
    case 'fast'
        % Get indicies such that cycle through all colours before incrementing
        % the property indices. For example, if nw==11, ncol==3 we expect:
        %   dataset index    1  2  3  4  5  6  7  8  9  10  11
        %   colour index     1  2  3  1  2  3  1  2  3   1   2
        %   property index   1  1  1  2  2  2  3  3  3   4   4
        [varargout{1}, ix] = ind2sub([ncol, ceil(nw/ncol)], 1:nw);
end

% Now get each property index modulo the number of properties
for i=1:numel(n)
    varargout{i+1} = ixmod(ix, n(i));
end
