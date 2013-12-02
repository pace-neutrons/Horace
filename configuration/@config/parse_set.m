function [S,save,ok,mess] = parse_set (this,varargin)
% Check arguments are valid for a custom set method. Throws an error if a field is not valid or is sealed.
%
% Set save-to-file flag as '-save':
%   >> [S,save,ok,mess] = parse_set (config_obj, field1, val1, field2, val2, ...)
%   >> [S,save,ok,mess] = parse_set (config_obj, struct)
%   >> [S,save,ok,mess] = parse_set (config_obj, cellnam, cellval) % Cell arrays of field names and values
%   >> [S,save,ok,mess] = parse_set (config_obj, cellarray)        % Cell array has the form {field1,val1,field2,val2,...}
%
% Cases that return all fields (and save-to-file flag set to '-save')
%   >> [S,save,ok,mess] = parse_set (config_obj)                   % Returns current values
%   >> [S,save,ok,mess] = parse_set (config_obj, 'defaults')       % Returns default values
%   >> [S,save,ok,mess] = parse_set (config_obj, 'saved')          % Returns saved values%
%
% All the above follow the default behaviour to save to file:
%   >> [S,save,ok,mess] = parse_set (config_obj, ..., '-save')
%
% Set save-to-file flag as '-buffer':
%   >> [S,save,ok,mess] = parse_set (config_obj, ..., '-buffer')
%
% Input:
% ------
%   config_obj  Configuration object 
%
% Output:
% -------
%   S           Structure with the fields of configuration object, and with
%              values updated according to the input arguments
%
%   save        Save-to-file request: '-save' (save to file) or '-buffer' (save in buffer only)
% 
%
% EXAMPLES:
%   >> [S,save,ok,mess] = parse_set (my_config,'a',10,'b','something')
%
%   >> [S,save,ok,mess] = parse_set (my_config,'a',10,'b','something','-buffer')
%
%   >> [S,save,ok,mess] = parse_set (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% This method is designed for use in custom set methods. See the example in test2_config

% $Revision$ ($Date$)


[S,save,ok,mess] = parse_set_internal (this, false, varargin{:});
if ~ok, return, end

% Remove 'sealed_fields' as this cannot be set in a custom set method
S=rmfield(S,'sealed_fields');
