function set(this,varargin)
% Set one or more fields in a configuration
%
%   >> set(config, field1, val1, field2, val2, ... )
%   >> set(config, struct )
%   >> set(config, cellarray)     % cell array has the form {field1,val1,field2,val2,...}
%   >> set(config,'defaults')
% 
% $Revision:  $ ($Date:  $)
%
if strcmp(varargin{1},'-change_sealed')
    error('CONFIG:set','Change of sealed fields is prohibited in set function')
end

set_internal(this,varargin{:});
