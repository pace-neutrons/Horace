function this=set(this,varargin)
% Set one or more fields in the example configuration object test2_config
%
%   >> var = set (configobj, arg1, arg2, ...)
%
% Input:
%   configobj           Configuration object
%   arg1, arg2,...      Arguments according to one of the useage options below
%
% Output:
%   var                 Copy of configuration object
%
% Syntax for different input arguments:
% -------------------------------------
%   >> var = set(configobj, field1, val1, field2, val2, ... )
%   >> var = set(configobj, struct )
%   >> var = set(configobj, cellnam, cellval)  % cell arrays of field names and values
%   >> var = set(configobj, cellarray)         % cell array has the form {field1,val1,field2,val2,...}
%
%   >> var = set(configobj)                    % Leaves configobj unchanged
%   >> var = set(configobj,'defaults')         % Sets to default values configuration
%
%
% In this example, the sealed field v4 is set according to sign of the open field v1


S=parse_set(this,varargin{:});

if isfield(S,'v1')    % determine if v1 is one of the input
    if isnumeric(S.v1) && isscalar(S.v1)
        if S.v1>=0
            S.v4='positive';
        else
            S.v4='negative';
        end
    else
        S.v4='undefined';
    end
end

this=set_internal(this,'-change_sealed',S);
