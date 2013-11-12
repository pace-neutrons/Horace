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

[S,save,ok,mess] = parse_set (this,varargin{:});
if(~ok)
    error('HERBERT_CONFIG:set',['invalid set parameter: ',mess]);
end

if isfield(S,'init_tests')
  change_to = S.init_tests;
  rootpath = fileparts(which('herbert_init'));
  xunit_path= fullfile(rootpath,'_test/matlab_xunit/xunit');  % path for unit tests    
  common_path= fullfile(rootpath,'_test/common_functions');  % path for unit tests        

  if change_to > 0
        addpath(common_path);              
        addpath(xunit_path);
  else
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)        
        rmpath(xunit_path);
        rmpath(common_path);        
        warning(warn_state);    % return warnings to initial state        
  end
  
end

% overload set in an peculiar non-oop way which is currently the only way
% to do it on config.
[this,ok,mess]=set_internal(this,false,varargin{:});
if ~ok, error(mess), end


function ss= all_to_string(x)
    if ~isstring(x)
        ss=num2str(x);
    else
        ss = x;
    end
