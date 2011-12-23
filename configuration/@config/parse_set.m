function S = parse_set (this,varargin)
% Check arguments are valid for set methods. Throws an error if a field is sealed.
%
%   >> S = parse_set (configobj, field1, val1, field2, val2, ...)
%   >> S = parse_set (configobj, struct)
%   >> S = parse_set (configobj, cellnam, cellval) % cell arrays of field names and values
%   >> S = parse_set (configobj, cellarray)        % cell array has the form {field1,val1,field2,val2,...}
%
%   >> S = parse_set (configobj)                   % returns current values
%   >> S = parse_set (configobj, 'defaults')       % returns default values
%
% For any of the above:
%   >> S = parse_set (configobj,...)
%
% Input:
%   configobj   Configuration object
%
% Output:
%   S           Structure whose fields and values are those to be changed
%               in the configuration object
% 
% EXAMPLES:
%   >> S = parse_set (my_config,'a',10,'b','something')
%
%   >> S = parse_set (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% This method is designed for use in custom set methods. See the example in test2_config

% $Revision: 120 $ ($Date: 2011-12-20 18:18:12 +0000 (Tue, 20 Dec 2011) $)

S = parse_set_internal (this, false, varargin{:});
