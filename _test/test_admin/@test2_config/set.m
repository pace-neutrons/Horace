function this=set(this,varargin)
% Set one or more fields in the example configuration object test2_config
%
%   >> var = set (configobj, arg1, arg2, ...)
%
% Input:
% ------
%   configobj           Configuration object
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
%   >> var = set(config_obj, cellnam, cellval)  % cell arrays of field names and values
%   >> var = set(config_obj, cellarray)         % cell array has the form {field1,val1,field2,val2,...}
%
%   >> var = set(config_obj)                    % Leaves configobj unchanged
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
%
%
% In this example, the sealed field v4 is set according to sign of the open field v1


%--------------------------------------------------------------------------------------------------
% Get config structure with updated public fields
[S,save_status,ok,mess]=parse_set(this,varargin{:});
if ~ok, error('TESTCONFIG:set_invalid_argument',mess), end

%--------------------------------------------------------------------------------------------------
% === Alter the code only in this section ===
% You can do a couple of things here safely;
%   - Run functions that depend on the value of configuration fields
%   - Change sealed fields
%
% The following provisos apply:
%
%   Update sealed fields only with values that depend only on the 
%   public fields (i.e. the unsealed fields). If this convention is not 
%   followed, then the configuration is not a state function of the public
%   fields. Instead, it may depend on the previous history of the configuration.

if isnumeric(S.v1) && isscalar(S.v1)
    if S.v1>=0
        S.v4='positive';
    else
        S.v4='negative';
    end
else
    S.v4='undefined';
end

%--------------------------------------------------------------------------------------------------
% Update the configuration object, saving to file if required
[this,ok,mess]=set_internal(this,'-change_sealed',S,save_status);
if ~ok, error(mess), end
