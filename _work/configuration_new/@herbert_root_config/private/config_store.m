function varargout = config_store (varargin)
% Store or retrive current configuration structure. Do not edit this function.
% 
% Store the configuration:
%   >> config_store (config_name, current_structure)
%   >> config_store (config_name, current_structure, default_structure)
%   >> config_store (config_name, current_structure, default_structure, config_object)
%
% Retrieve the configuration class:
%   >> [created,root_config_object] = config_store
%       created             True if the root_configuration class has been created, false otherwise
%       config_object       Instance of the root configuration class, if it configuration has been created
%                           Empty if the root configuration has not been created
%
%   >> [created,config_class] = config_store(config_name)
%       created             True if the named configuration class has been created, false otherwise
%       config_object       Instance of the named configuration class, if it has been created
%                           Empty if the named configuration has not been created
%
% Retrieve the configuration:
%   >> all_config_data = config_store(fetch_default)
%       fetch_default=false Fetch previously stored current configurations
%       fetch_default=true  Fetch previously stored default configurations
%
%       all_config_data     Structure with fields matching names of all configurations, and each field
%                      contains a structure whose fields are those of the configuration.
%
%   >> config_data = config_store(config_name,fetch_default)
%       fetch_default=false Fetch previously stored current named configuration
%       fetch_default=true  Fetch previously stored default named configuration
%
%       config_data         Structure with fields containing data of corresponding field of the named configuration
%
% No error checking on the consistency or type of the input arguments is performed,
% as it is assumed that this is has been done by the calling method.

% $Revision: 128 $ ($Date: 2012-01-23 08:30:12 +0000 (Mon, 23 Jan 2012) $)


persistent config_created root_config_object config_objects current_configs default_configs

if isempty(config_created)
    config_created=false;
    root_config_object=[];
    config_objects=struct;         % make empty structure
    current_configs=struct;
    default_configs=struct;
end

% Store or retrieve as required, with the structure of the code such that the operations
% that need to be fastest are reached soonest, namely retrieving the 
if numel(varargin)==0
    if config_created
        varargout{1}=true;
        if nargout>1, varargout{2}=root_config_object; end
    else
        varargout{1}=false;
        varargout{2}=[];
    end
else
    if ~islogical(varargin{1})  % assume first argument is a valid object name
        if numel(varargin)==1
            try
                varargout{1}=true;
                varargout{2}=config_objects.(varargin{1});  % must actually try to read to know if object really is created
            catch
                varargout{1}=false;
                varargout{2}=[];
            end
        elseif islogical(varargin{2})
            try
                if varargin{2}
                    varargout{1}=default_configs.(varargin{1});
                else
                    varargout{1}=current_configs.(varargin{1});
                end
            catch
                error(['Stored configuration in memory is incomplete or non-existent for configuration class %s.\n',...
                       'This circumstance should only occur if you are a developer'],varargin{1})

            end
        else
            current_configs.(varargin{1})=varargin{2};
            if numel(varargin)==3, default_configs.(varargin{1})=varargin{3}; end
            if numel(varargin)==4
                config_objects.(varargin{1})=varargin{4};
                if isfield(struct(varargin{4}),'ok')    % the distinguishing field of the root configuration
                    root_config_object=varargin{4};
                    config_created=true;
                end
            end
        end
    else
        if varargin{1}
            varargout{1}=default_configs;
        else
            varargout{1}=current_configs;
        end
    end
end
