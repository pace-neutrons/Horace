function set(this,varargin)
% Set one or more fields in a configuration
%
%   >> set(config, field1, val1, field2, val2, ... )
%   >> set(config, struct )
%   >> set(config, cellarray)     % cell array has the form {field1,val1,field2,val2,...}
%   >> set(config,'defaults')


config_name = class(this);               % class name of incoming object
set_internal(this,config_name,varargin{:});
