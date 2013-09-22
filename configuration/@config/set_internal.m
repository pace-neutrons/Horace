function [this,ok,mess]=set_internal(this,varargin)
% Set one or more fields in a configuration object, optionally allowing the sealed fields to be changed
%
%   >> set_internal (config_obj, change_sealed, arg1, arg2, ...)
%   >> [var,ok,mess] = set_internal (config_obj, change_sealed, arg1, arg2, ...)
%
% *** NOTE: This method has to be public because it is used by customised set methods for
%           configuration objects. It should not be used in any other context.
%
% Input:
% ------
%   config_obj      Configuration object
%   change_sealed   Indicates if sealed fields can be altered.
%                   '-change_sealed' or '-nochange_sealed'
%                         true       or        false
%                           1        or          0
%   arg1, arg2,...  Arguments according to one of the useage options below
%
% Output:
% -------
%   var             Copy of configuration object
%
%
% Syntax for different input arguments:
% -------------------------------------
% Change values (and also save to file):
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed, field1, val1, field2, val2, ... )
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed, struct )
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed, cellnam, cellval)  % Cell arrays of field names and values
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed, cellarray)         % Cell array has the form {field1,val1,field2,val2,...}
%
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed)                    % Leaves configobj unchanged
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed,'defaults')         % Sets to default values configuration
%   >> [var,ok,mess] = set_internal(config_obj, change_sealed,'saved')            % Sets to saved values configuration
%
% All the above follow the default behaviour to save to file:
%   >> [var,ok,mess] = set_internal(config_obj, ..., '-save')
%
% To change values, but accumulate in buffer without saving to file:
%   >> [var,ok,mess] = set_internal(config_obj, ..., '-buffer')
%
%   Note: a subsequent change that does explicitly accumulate in the buffer will
%   save all changes in the buffer as well.

% $Revision$ ($Date$)


% Get structure for the config object, with field values updated according to the input arguments
[S,save,ok,mess] = parse_set_internal(this,varargin{:});
if ~ok, return, end

% Save data into the corresponding configuration file and into memory;
config_name = class(this);               % class name of incoming object
file_name = config_file_name (config_name);
if strcmp(save,'-save')
    [ok,mess]=save_config(file_name,S);
    if ~ok, return, end
end
config_store(config_name,S)
