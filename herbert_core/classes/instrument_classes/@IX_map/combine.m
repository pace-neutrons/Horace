function obj_out = combine (varargin)
% Combine several IX_map objects to form a single IX_map
%
%   >> obj_out = combine (obj1, obj2, obj3, ...)
%
% The spectra for workspaces with the same workspace numbers but in different
% IX_map objects are collected into a single workspace in the out IX_map.
%
% This method differs from IX_map method concatenate which 
%
% See also: concatenate
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
%       workspace 5: spectra [51,52,53,54,55]
%       workspace 7: spectra [71,72]
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
nwkno = arrayfun(@(x)(x.nwkno), map);   % column with no. workspaces in each map
iwhi = cumsum(nwkno);
iwlo = iwhi - nwkno + 1;

nstot = arrayfun(@(x)(x.nstot), map);   % column with no. spectra in each map
ishi = cumsum(nstot);
islo = ishi - nstot + 1;

wkno = NaN(1, iwhi(end));
ns = NaN(1, iwhi(end));
s = NaN(1, ishi(end));
for i=1:numel(map)
    if nwkno(i) > 0    % no work to do if no workspaces
        wkno(iwlo(i):iwhi(i)) = map(i).wkno;
        ns(iwlo(i):iwhi(i)) = map(i).ns;
        s(islo(i):ishi(i)) = map(i).s;
    end
end

% Create output IX_map
obj_out = IX_map(s, 'wkno', wkno, 'ns', ns);
