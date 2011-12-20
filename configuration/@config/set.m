function this=set(this,varargin)
% Set one or more fields in a configuration
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

if strcmp(varargin{1},'-change_sealed')
    error('CONFIG:set','Change of sealed fields is prohibited in set function')
end

this=set_internal(this,false,varargin{:});
