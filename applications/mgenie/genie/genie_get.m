function var = genie_get (nam)
% Get named variable from ISIS raw file.
%
%   >> var=genie_get(nam)   % return value of named field
%   >> var=genie_get        % return default data source
%
% Nam must be one of the valid field names for an ISIS raw file. No checks
% are performed on the validity of the name before calling data access routines.
%
% Has the potential to be faster than using gget, but is less safe.
% Included for backwards compatibility.

if nargin==1
    var=genie_getvalue (nam);
else
    var=genie_getvalue;
end
