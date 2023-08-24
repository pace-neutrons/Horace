function [ind, ielmts, randfunc, args, split] = parse_rand_ind (varargin)
% Parse arguments for sampling an object array
%
%   >> [ind, ielmts, randfunc, args, split] = parse_rand_ind (varargin)
%
% Input:
% ------
%   varargin    Arguments to parse. Valid syntax is one of the following:
%
%                   >> [...] = rand_ind (ind, randfunc)
%                   >> [...] = rand_ind (ind, ielmts, randfunc)
%
%                   >> [...] = rand_ind (..., randfunc, p1, p2, ...)
%
%                   >> [...] = rand_ind (..., 'split', randfunc, p1, p2, ...)
%                   >> [...] = rand_ind (..., 'split', iargs, randfunc, p1, p2, ...)
%
%
% Output:
% -------
%   ind         Indices into the object
%   ielmts      Indices into elements of the object, if present
%               Set to [] if not present
%   randfunc    Handle to random sampling function
%   args        Cellarray (row) of arguments to pass to randfunc.
%               Empty if none (==cell(1,0)).
%   split       Logical row vector with length of args, true where an
%               argument is to be split


% Parse the input arguments
narg = numel(varargin);
if narg>=1
    ind = varargin{1};
else
    error('HERBERT:parse_rand_ind:invalid_argument',...
        'Insufficient number of input arguments')
end

if narg>=2 && isa(varargin{2},'function_handle')
    % (ind, randfunc,...)
    randfunc = varargin{2};
    args = varargin(3:end);
    split = false(size(args));
    ielmts = [];
    
elseif narg>=3 && isa(varargin{3},'function_handle')
    % (ind, ielmts, randfunc,...) or (ind, 'split', randfunc,...)
    randfunc = varargin{3};
    args = varargin(4:end);
    try
        % Try (..., 'split', randfunc,...)
        split = parse_split (numel(args), varargin{2});
        ielmts = [];
    catch
        split = false(size(args));
        ielmts = varargin{2};
    end
    
elseif narg>=4 && isa(varargin{4},'function_handle')
    % (ind, ielmts, 'split', randfunc,...) or (ind, 'split', iarg, randfunc,...)
    randfunc = varargin{4};
    args = varargin(5:end);
    try
        % Try (..., 'split', randfunc,...)
        split = parse_split (numel(args), varargin{3});
        ielmts = varargin{2};
    catch
        % Try (..., 'split', iargs, randfunc,...)
        try
            split = parse_split (numel(args), varargin{[2,3]});
            ielmts = [];
        catch ME
            rethrow (ME)
        end
    end
    
elseif narg>=5 && isa(varargin{5},'function_handle')
    % (ind, ielmts, 'split', iarg, randfunc,...)
    randfunc = varargin{5};
    args = varargin(6:end);
    try
        % Try (ind, ielmts, 'split', iarg, randfunc,...)
        split = parse_split (numel(args), varargin{[3,4]});
        ielmts = varargin{2};
    catch ME
        rethrow (ME)
    end
    
else
    error('HERBERT:parse_rand_ind:invalid_argument',...
        ['The handle to a random sampling function is missing or in an ',...
        'invalid position'])
end

% Check ind and ielmts have the same size
sz_ind = size(ind);
sz_ielmts = size(ielmts);
if ~isempty(ielmts)
    if numel(sz_ind)~=numel(sz_ielmts) || any(sz_ind~=sz_ielmts)
        error('HERBERT:parse_rand_ind:invalid_argument',...
            'Arguments ''ind'' and ''ielmts'' must have the same size')
    end
end
