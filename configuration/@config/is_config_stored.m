function [ok,varargout]=is_config_stored(this,config_name)
% Determine if the named configuration class shares the root configuration class with the input object
%
%   >> [ok,named_config_obj]=is_config_stored(config_obj,config_name)
%
% Input:
% ------
%   config_obj      Configuration object (only required to direct a call to this method)
%   config_name     Name of the configuration class
%
% Output:
% -------
%   ok              True if the configuration class is a child of the root
%                  configuration class and false if not
%   named_config_obj If ok, returns an instance of the named configuration class;
%                   if not ok, then empty

% Needed by the constructor of child configuration classes, but not expected to be
% needed otherwise, although it does exactly what the help advertises.

if nargout==2
    [ok,varargout{1}]=config_store(config_name);
else
    ok=config_store(config_name);
end
