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

% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)

options = {'defaults','saved','-buffer','-save'};
[ok,mess,set_defaults,set_saved,save_to_buffer,save_to_file,other_options]=parse_char_options(varargin,options);
if ~ok, error('CONFIG_BASE:set',mess); end

if this.saveable
    saveable = (~save_to_buffer || save_to_file);
    this.saveable = saveable;
end

if set_saved
    config_store.instance().clear_config(this);
end
if set_defaults &&~save_to_buffer
    config_store.instance().clear_config(this,'-file');
end

% transform other options into standard form
if set_defaults
    this.returns_defaults = true;
    S = this.get_defaults;
else
    [S,ok,mess] = parse_set_internal(other_options{:});
    if ~ok, error('CONFIG_BASE:set',mess); end
end


fields = fieldnames(S);
for i=1:numel(fields)
    this.(fields{i})= S.(fields{i});
end


