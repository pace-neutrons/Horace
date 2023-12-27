function obj_out = concatenate (varargin)
% Concatenate several IX_map objects to form a single IX_map
%
%   >> obj_out = combine (obj1, obj2, obj3, ...)
%
% The workspaces in a collection of IX_map objects are used to make a single
% IX_map object with those workspaces placed in sequence; the number of
% workspaces in the output is equal to the sum of number of workspaces in each
% of the input IX_map objects. The workspace numbers of all but the first IX_map
% are increased by the workspace number of the imeediately preceding IX_map, so
% that the workspace numbers remain unique.
%
% This compares with the IX_map method called combine in which workspaces with
% the same workspace numbers but in different IX_map objects are collected into
% a single workspace in the out IX_map.
%
% See also: combine
%
% EXAMPLE
%  Suppose map1 consists of
%       workspace 1: spectra [11,12]
%       workspace 5: spectra [51,52]
%  and map2 consists of
%       workspace 5: spectra [53,54,55]
%       workspace 7: spectra [71,72]
% then the output workspace consists of
%       workspace 1: spectra [11,12]
%       workspace 5: spectra [51,52]
%       workspace 6: spectra [53,54,55]     % workspace number increased
%       workspace 8: spectra [71,72]        % workspace number increased
%
% Input:
% ------
%   obj1, obj2,...  IX_map objects to be combined (each can be a scalar or an
%                   array of objects)
%
% Output:
% -------
%   obj_out         Single IX_map object that combines all the input objects


% Trivial case of scalar single input argument
if nargin==1 && isscalar(varargin{1})
    obj_out = varargin{1};
    return
end

% Check all input arguments are IX_map arrays
if ~all(cellfun(@(x)(isa(x,'IX_map')), varargin))
    error ('HERBERT:IX_map:invalid_argument',...
        'All input arguments must have class ''IX_map''')
end

% Combine into single array (make each a column beforehand)
map = cellfun(@(x)(x(:)), varargin, 'uniformOutput', false);
map = cat(1, map{:});

% Get full list of spectra and workspace numbers for all the maps
nstot = arrayfun(@(x)(x.nstot), map);   % column with no. spectra in each map
nend = cumsum(nstot);
nbeg = nend - nstot + 1;

spec = NaN(1,nend(end));
work = NaN(1,nend(end));
wmax_prev = 0;
for i=1:numel(map)
    if map(i).ns > 0    % no work to do if no spectra
        spec(nbeg(i):nend(i)) = map(i).s;        
        % If the smallest workspace number is less than or equal to the largest
        % from the processed previous map, then the workspace numbers for the 
        % present map must be processed by adding an offset so that the smallest
        % wowrkspace number becomes one greater than the largest in previous map
        work(nbeg(i):nend(i)) = map(i).w + max(0, (wmax_prev - map(i).wkno(1) + 1));
        wmax_prev = work(nend(i));  % update the previus maximum for the next loop
    end
end

% Create output IX_map
obj_out = IX_map(spec, 'wkno', work);
