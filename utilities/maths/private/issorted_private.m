function status = issorted_private (A,public)
% Determine if an array of structures or objects is in ascending order
%
%   >> status = issorted_private (A)            % default: public = true
%   >> status = issorted_private (A,public)
%
% Input:
% ------
%   A       Struct or object array to be tested (row or column vector)
%
%   public  Logical flag: (Default: true)
%            true:  Keep public properties (independent and dependent)
%                   More specifically, it calls an object method called
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%            false: Keep independent properties only (hidden, protected and
%                   public)
%                   More specifically, it calls an object method called
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.
%
% Output:
% -------
%   status  True if sorted in ascending order
%           Specifically, the test ~greater_than(A(i-1),A(i),public) is true
%          for all i>1


if isstruct(A) || isobject(A)
    if ~isvector(A), error('Only sorts vectors'), end
    if numel(A)>1
        mono_increase = true(numel(A),1);
        for i=2:numel(A)
            mono_increase = ~greater_than_private(A(i-1),A(i),public);
        end
        status = all(mono_increase(:));
    else
        status = true;
    end
else
    error('Can only check structure or object arrays')
end
