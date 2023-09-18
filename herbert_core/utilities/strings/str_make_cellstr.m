function [ok, cout] = str_make_cellstr (varargin)
% Try to make a cellstr of strings from a set of input arguments
%
%   >> [ok, cout] = str_make_cellstr (c1, c2, c3,...)
%
% Input:
% ------
%   c1,c2,c3,...    Two-dimensional character arrays, cell arrays of strings,
%                  or string array (Matlab release R2016b onwards)
%
% Output:
% -------
%   ok              Logical flag: true if valid input, false if conversion not
%                  possible
%
%   cout            Column vector cellstr
%                   Trailing whitespace is removed from character strings 
%                  created from 2D character arrays, but not from Matlab
%                  string objects (this is for consistency with what
%                  cellstr does)


narg = numel(varargin);

% Get number of strings
n = zeros(narg,1);
for i=1:narg
    if iscellstr(varargin{i})
        n(i) = numel(varargin{i});
    elseif ischar(varargin{i}) && numel(size(varargin{i}))==2
        if ~isempty(varargin{i})
            n(i) = size(varargin{i},1);
        else
            n(i) = numel(cellstr(varargin{i}));   % so the empty string is stored
        end
    elseif isa(string(),'string') && isstring(varargin{i})
        % Matlab string object. Note the check that string() produces an
        % object of class 'string'. About two orders of magnitude faster
        % than using Matlab intrinsic function verLessThan to check the 
        % Matlab version in order to determine if string() is supported.
        n(i) = numel(varargin{i});
    else
        ok = false;
        cout = cell(0,1);
        return
    end
end

% Fill up output cellstr
nend = cumsum(n);
nbeg = nend - n + 1;
if nend(end)>0
    cout = cell(nend(end),1);
    for i=1:narg
        if iscellstr(varargin{i})
            cout(nbeg(i):nend(i)) = varargin{i};
        else
            cout(nbeg(i):nend(i)) = cellstr(varargin{i});
        end
    end
else
    cout = {};
end

ok = true;

end
