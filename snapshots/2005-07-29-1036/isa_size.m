function ans = isa_size (var, check_size, check_type)
% Check if a variable has both a given type and size. Utility routine, but
% probably not very efficient if needed in a large loop.
%
% Syntax:
%   >> ans = isa_size (var, check_size)
%   >> ans = isa_size (var, check_size, check_type)
%
% Input:
% ------
%   var         Variable to be checked
%   check_size  Required size of variable
%                - the size of the array e.g. [2,3] or [1,1] or [4,5,100]
%                - 'row' if a row vector of unspecified length
%                - 'column' if a column vecto of unspecified length
%
%   check_type  Matlab variable type to check against.
%               In addition, will accept 'cellstr' (not a recognised
%              keyword by the matlab intrinsic function 'isa', as it
%              is not a class, but a special case of a cell)
%
% Output:
% --------
%   ans         =1 if var has desired type and size
%               =0 otherwise
%
%   e.g. check if variable w is a 4x3 matrix of type double:
%   >> yes = isa_size (w, [4,3], 'double')
%
%   e.g. is variable w a row vector:
%   >> ans = isa_size (w, [1,3], 'double')
%

% T.G.Perring 15 July 2005


if nargin<=1
    error ('ERROR: Check number of arguments')
end

% Check the size
size_ok = 0;
if isnumeric(check_size) & length(size(check_size))==2 & size(check_size,1)==1
    var_size = size(var);
    if length(var_size)==length(check_size)
       if var_size==check_size
            size_ok = 1;
        end
    end
elseif ischar(check_size)
    if strcmp(lower(check_size),'row')
        if length(size(var))==2 & size(var,1)==1
            size_ok = 1;
        end
    elseif strcmp(lower(check_size),'column')
        if length(size(var))==2 & size(var,2)==1
            size_ok = 1;
        end
    else
        error ('ERROR: check_size keyword must be ''row'' or ''column''')
    end
else
    error ('ERROR: Check that check_size is a numeric row vector (in isa_size)')
end

% Check the type
if nargin==3
    type_ok = 0;
    if ischar(check_type) & length(size(check_type))==2 & size(check_type,1)==1
        if isa(var,check_type)
            type_ok = 1;
        elseif strcmp(lower(check_type),'cellstr') & iscellstr(var)   % catch special case of a cell array of strings
            type_ok = 1;
        end
    else
        error ('ERROR: Check that check_type is a character string (in isa_size)')
    end
else
    type_ok = 1;
end    

ans = size_ok & type_ok;

    