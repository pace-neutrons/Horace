function varargout = config_store (config_name, varargin)
% Store or retrive current configuration structure. Do not edit this function.
% 
% Store the configuration:
%   >> config_store (config_name, current_structure, default_structure)
%
% Retrieve the configuration:
%   >> config_data = config_store(config_name,default)
%       default=false   fetch previously stored current configuration
%       default=true    fetch previously stored default configuration
%
%   >> all_config_data = config_store(default)
%       default=false   fetch all previously stored current configurations
%       default=true    fetch all previously stored default configurations
%
% No error checking on the consistency or type of the input arguments is performed,
% as it is assumed that this is has been done by the calling method.
% 
% $Revision:  $ ($Date:  $)
%


global current_configuration default_configuration

if numel(varargin)==2        % store current and default configurations
    current_configuration.(config_name)=varargin{1};
    default_configuration.(config_name)=varargin{2};
    
elseif numel(varargin)==1 
    if isstruct(varargin{1})    % store current configuration only
        current_configuration.(config_name)=varargin{1};   
    elseif isa(varargin{1},'char') && strcmp(varargin{1},'getall')  % return all current configurations
        varargout{1} = current_configuration;
    else     % retrieve configuration

        fetch_default=varargin{1};
        if ~fetch_default && ~isempty(current_configuration) && isfield(current_configuration,config_name)
            varargout{1}=current_configuration.(config_name);
        elseif fetch_default && ~isempty(default_configuration) && isfield(default_configuration,config_name)
            varargout{1}=default_configuration.(config_name);
        else
            error(['Stored configuration in memory is incomplete or non-existent for configuration class %s.\n',...
               'This circumstance should only occur if you are a developer'],config_name)
        end
    end
elseif numel(varargin)==0
    default=config_name;
    if ~default
        varargout{1}=current_configuration;
    else
        varargout{1}=default_configuration;
    end
    
else
    error('Logic error in code')
end
