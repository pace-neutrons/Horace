function [S,present] = parse_args_namelist (namelist, varargin)
% Parses input arguments into a list
%
%   >> [S, present] = parse_args_namelist (namelist, p1, p2, ...
%                                           name1, val1, name2, val2, ...)
%
% Positional arguments are used to assign values to the names in the order
% they appear in namelist, and name-value pairs are used to assign values
% to specific names. The anmes can be abbreviated so long as the abbreviation
% is unambiguous and doesnt clash with another unabbreviated name.
%
% Names can only be assigned values once, otherwise an error is thrown (as
% if the error was in the calling function)
%
% Input
% -----
%   namelist        Cell array of argument names. Assumed to be unique and
%                   non-empty character strings
%
%   p1,p2,...       One or more values of arguments in the oder that they
%                   appear in namelist
%
%   name1, val1...  Name-value pairs where the names are in namelist
%                   preceded by '-' e.g. '-moderator'
%
% Output:
% -------
%   S               Structure with fields given by the names of arguments
%                   and corresponding values that appeared in the input
%
%   present         Structure with fields given by namelist, each field
%                   with value true or false according to whether or not
%                   the corresponding name was assigned a value


nnames = numel(namelist);
nchars = cellfun(@numel,namelist);

% Find first occurence of a name
narg = numel(varargin);
if narg==0  % case of no input
    % names = cell(1,0);
    % vals = cell(1,0);
    S = struct();
    present = cell2struct(num2cell(false(1,nnames)),namelist,2);
    return
end

npositional = narg;
for i=1:narg
    ix = isname(varargin{i}, namelist, nchars);
    if ~isempty(ix)
        if ix>0
            npositional = i-1;
            break
        else
            ME = MException('parse_args_namelist:inputError',...
                ['Ambiguous argument name at position ',num2str(i)]);
            throwAsCaller(ME)
        end
    end
end

% Assign
if npositional<=nnames
    if npositional<narg    % at least one name
        if rem(narg-npositional,2)==0
            nset = [ones(1,npositional),zeros(1,nnames-npositional)];
            ind = [1:npositional,zeros(1,nnames-npositional)];
            for i=npositional+1:2:narg
                if i>npositional+1    % already checked first name is valid
                    ix = isname(varargin{i}, namelist, nchars);
                    if isempty(ix)
                        ME = MException('parse_args_namelist:inputError',...
                            ['Expected an argument name at position ',num2str(i)]);
                        throwAsCaller(ME)
                    elseif ix==0
                        ME = MException('parse_args_namelist:inputError',...
                            ['Ambiguous argument name at position ',num2str(i)]);
                        throwAsCaller(ME)
                    end
                end
                nset(ix) = nset(ix)+1;
                ind(ix) = i+1;  % index of value
            end
            if all(nset<=1)
                set = (nset==1);
                names = namelist(set);
                vals = varargin(ind(set));
            else
                ME = MException('parse_args_namelist:inputError',...
                    'Names can only be given values once');
                throwAsCaller(ME)
            end
        else
            ME = MException('parse_args_namelist:inputError',...
                'Expected name-value pairs following any positional arguments');
            throwAsCaller(ME)
        end
    else
        set = [true(1,narg),false(1,nnames-narg)];
        names = namelist(1:narg);
        vals = varargin(1:narg);
    end
else
    ME = MException('parse_args_namelist:inputError',...
        'Too many positional arguments');
    throwAsCaller(ME)
end

S = cell2struct(vals, names, 2);
present = cell2struct(num2cell(set),namelist,2);

%--------------------------------------------------------------------------
function ix = isname(val,namelist,nchars)
% Determine if an argument has the form '-nam' where 'nam' is an
% unambiguous abbreviation of one of the names in the cell array names
%
% ix is empty if not of the form above.
% ix==0  if val is not uniquely one of the names
% ix>=1  is the index of the name in namelist

if ischar(val) && numel(size(val))==2 && size(val,1)==1 &&...
        size(val,2)>1 && val(1:1)=='-'
    n = numel(val)-1;
    ix = find(strncmpi(val(2:end),namelist,n));
    if numel(ix)>1
        ix = ix(n==nchars);
        if ~isscalar(ix)
            ix = 0;
        end
    end
else
    ix = [];
end

%--------------------------------------------------------------------------
function S = make_structure (names, vals)
% Make a scalar structure from the names and values. Looks after the case
% cell array values - turns them into scalar cell arrays

S = cell2struct(vals, names, 2);

% vals_tmp = cellfun(@(x)cellify(x), vals, 'uniformoutput', false);
% S = cell2struct(vals_tmp, names, 2);
% 
% function xout = cellify(x)
% if iscell(x)
%     xout = {x};
% else
%     xout = x;
% end
