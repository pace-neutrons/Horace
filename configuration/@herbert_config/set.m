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

% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)


%--------------------------------------------------------------------------------------------------
% Get config structure with updated public fields
[S,save_status,ok,mess] = parse_set (this,varargin{:});
if ~ok, error('HERBERT_CONFIG:set',['invalid set parameter: ',mess]); end

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

rootpath = fileparts(which('herbert_init'));
xunit_path= fullfile(rootpath,'_test/matlab_xunit/xunit');  % path for unit tests
common_path= fullfile(rootpath,'_test/common_functions');   % path for unit tests

if S.init_tests
    addpath(common_path);
    addpath(xunit_path);
else
    warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
    rmpath(xunit_path);
    rmpath(common_path);
    warning(warn_state);    % return warnings to initial state
end

%--------------------------------------------------------------------------------------------------
% Update the configuration object, saving to file if required
[this,ok,mess]=set_internal(this,'-change_sealed',S,save_status);
if ~ok, error(mess), end
