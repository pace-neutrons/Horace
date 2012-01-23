function varargout = config_store (config_name, varargin)
% Store or retrive current configuration structure. Do not edit this function.
% 
% Store the configuration:
%   >> config_store (config_name, current_structure)
%   >> config_store (config_name, current_structure, default_structure)
%
% Retrieve the configuration:
%   >> config_class = config_store(config_name)
%       config_present  =true if named configuration has been loaded; false if not
%
%   >> config_data = config_store(config_name,default)
%       default=false   fetch previously stored current configuration
%       default=true    fetch previously stored default configuration
%       config_data     structure with fields containing data of corresponding field of the configuration
%
%   >> all_config_data = config_store(default)
%       default=false   fetch all previously stored current configurations
%       default=true    fetch all previously stored default configurations
%       all_config_data structure with fields matching names of all configurations, and each field
%                      contains a structure whose fields are those of the configuration.
%
% No error checking on the consistency or type of the input arguments is performed,
% as it is assumed that this is has been done by the calling method.

% $Revision$ ($Date$)


global configuration_classes_data

% Initialise global storage if empty
% -----------------------------------
if isempty(configuration_classes_data)
    configuration_classes_data.current=[];
    configuration_classes_data.default=[];
end

% Set or retrieve configuration data
% ----------------------------------
if numel(varargin)==2
    % Store current and default configurations
    configuration_classes_data.current.(config_name)=varargin{1};
    configuration_classes_data.default.(config_name)=varargin{2};
    
elseif numel(varargin)==1 && isstruct(varargin{1})
    % Store current configuration only; the configuration will already exist
    configuration_classes_data.current.(config_name)=varargin{1};    

elseif numel(varargin)==1
    % Retrieve configuration; cautious retrieval in case corrupted
    fetch_default=varargin{1};
    if ~fetch_default && ~isempty(configuration_classes_data.current) && isfield(configuration_classes_data.current,config_name)
        varargout{1}=configuration_classes_data.current.(config_name);
    elseif fetch_default && ~isempty(configuration_classes_data.default) && isfield(configuration_classes_data.default,config_name)
        varargout{1}=configuration_classes_data.default.(config_name);
    else
        error(['Stored configuration in memory is incomplete or non-existent for configuration class %s.\n',...
               'This circumstance should only occur if you are a developer'],config_name)
    end
elseif numel(varargin)==0
    if ischar(config_name)
        if isfield(configuration_classes_data.current,config_name)
            varargout{1}=true;
        else
            varargout{1}=false;
        end
    else
    default=config_name;
    if ~default
            varargout{1}=configuration_classes_data.current;
    else
            varargout{1}=configuration_classes_data.default;
        end
    end
    
else
    error('Logic error in code')
end
