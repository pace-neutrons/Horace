function varargout= get(this,varargin)
% Get values of one or more fields from a configuration class
%
%   >> S = get(config_obj)      % returns a structure with the current values
%                               % of the fields in the requested configuration object
%
%   >> S = get(config_obj,'-public')    % returns only the values of public fields
%                                       % i.e. omits sealed fields
%
%   >> [val1,val2,...] = get(config_obj,'field1','field2',...); % returns named fields
%
% Recursively searches the sub-structures and classes of the configuration class
% until a field with the given name is found.

% $Revision$ ($Date$)

% Fetch the current configuration
config_name = class(this);
fetch_default=false;
config_data = config_store(config_name,fetch_default);

% Determine if only public fields to be read
if numel(varargin)>0 && ischar(varargin{end}) && ~isempty(varargin{end}) && ...
        size(varargin{end},1)==1 && size(varargin{end},2)>1 && strncmpi(varargin{end},'-public',length(varargin{end}))
    public_only=true;
    narg=numel(varargin)-1;
else
    public_only=false;
    narg=numel(varargin);
end

% Return if full structure is required, stripping out sealed fields if requested
if narg==0
    if public_only
        config_data=rmfield(config_data,[config_data.sealed_fields,{'sealed_fields'}]);
    end
    varargout{1}=config_data;
    return
end

% Check arguments are valid field names
if valid_fieldnames(varargin(1:narg))
    if public_only && (any(ismember(varargin(1:narg),config_data.sealed_fields)) || ...
                       any(strcmp('sealed_fields',fieldnames(config_data))))
        error('If the ''-public'' option is given then cannot return the value of a sealed field')
    end
else
    error('All field names have to be valid field names'); 
end

% Get values
varargout=cell(1,min(max(1,nargout),narg));  % return at least one value
for i=1:numel(varargout)
    [data_field,found]=get_field_in_hierachy(config_data,varargin{i});
    if found
        varargout{i}=data_field;
    else
        error('The field ''%s'' does not exist in configuration %s at any depth',varargin{i},config_name);    
    end    
end

%--------------------------------------------------------------------------------------------------
function [val,found]=get_field_in_hierachy(structure,field_name)
% Recursively searches through the hierarchy of structures and classes looking
% for the field name specified.
% Returns after finding the first field that is not a class or structure with the name
% requested, and sets found==true. Note that val will be empty if the field was empty.
% If the field is not found, then returns an empty variable and set found==false.
%
% Note: if a class is found in the list, we know it can not be a configuration class
% because this was forbidden in the constructor (check_fields_valid as called by
% build_configuration). Therefore we do not need to test if a field name appears in
% a list called 'sealed_fields' because if there is a field wit this name, its meaning is
% not constrained by the purpose of the field in a configuration class.

val=[];     % must account for the case that the structure is empty i.e. no fields
found=false;

if isfield(structure,field_name)
    % If field name, get data and return
    val=structure.(field_name);
    found=true;
else
    % Search for the field in classes or structures (if an array of structures or objects, use first element)
    names=fields(structure);
    for i=1:numel(names)
        if isstruct(structure.(names{i}))
            [val,found]=get_field_in_hierachy(structure.(names{i})(1),field_name);  % look in first member of an array of objects
        elseif isobject(structure.(names{i}))
            [val,found]=get_field_in_hierachy(struct(structure.(names{i})(1)),field_name);  % look in first member of an array of objects
        end
        if ~found
            return;
        end
    end
end
