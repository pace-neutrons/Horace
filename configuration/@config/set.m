function this=set(this,varargin)
% Set one or more fields in a configuration object
%
%   >> set (config_obj, arg1, arg2, ...)
%   >> var = set (config_obj, arg1, arg2, ...)
%
% Input:
% ------
%   config_obj          Configuration object
%   arg1, arg2,...      Arguments according to one of the useage options below
%
% Output:
% -------
%   var                 Copy of configuration object
%
% Syntax for different input arguments:
% -------------------------------------
% Change values (and also save to file):
%   >> var = set(config_obj, field1, val1, field2, val2, ... )
%   >> var = set(config_obj, struct )
%   >> var = set(config_obj, cellnam, cellval)  % Cell arrays of field names and values
%   >> var = set(config_obj, cellarray)         % Cell array has the form {field1,val1,field2,val2,...}
%
%   >> var = set(config_obj)                    % Leaves config_obj unchanged
%   >> var = set(config_obj,'defaults')         % Sets to default values configuration
%   >> var = set(config_obj,'saved')            % Sets to saved values configuration
%
% All the above follow the default behaviour to save to file:
%   >> var = set(config_obj, ..., '-save')
%
% To change values, but accumulate in buffer without saving to file:
%   >> var = set(config_obj, ..., '-buffer')
%
%   Note: a subsequent change that does explicitly accumulate in the buffer will
%   save all changes in the buffer as well.

% $Revision$ ($Date$)

[this,ok,mess]=set_internal(this,false,varargin{:});
if ~ok, error(mess), end
