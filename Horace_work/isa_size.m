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
%   check_size  Required size of variable e.g. [2,3] or [1,1] or [4,5,100]
%
%   check_type  Matlab variable type to check against
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

size_ok = 0;
if nargin>=2
    if isnumeric(check_size) & length(size(check_size))==2 & size(check_size,1)==1
        var_size = size(var);
        if length(var_size)==length(check_size)
            if var_size==check_size
                size_ok = 1;
            end
        end
    else
        error ('ERROR: Check that check_size is a numeric row vector (in isa_size)')
    end
end

type_ok = 1;
if nargin==3
    if ischar(check_type) & length(size(check_type))==2 & size(check_type,1)==1
        if ~isa(var,check_type)
            type_ok = 0;
        end
    else
        error ('ERROR: Check that check_type is a character string (in isa_size)')
    end
end    

ans = size_ok & type_ok;
    