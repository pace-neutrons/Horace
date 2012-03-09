function default_values =get_defaults(this,varargin)
% method returns default values, defined by default fields of 
% the class 
%
% $Revision$ ($Date$)
% 
if nargin==1
    default_values=this.the_fields_defaults;
    return
end

% reduce input to standard form (cellarray of strings)
if iscell(varargin)
    if numel(varargin)==1 && iscell(varargin{1})
        fields_needed =varargin{1};
    else
        fields_needed =varargin;
    end
else
    fields_needed = {varargin};
end

% check if all fields requested have defaults
have_defaults=ismember(fields_needed,this.fields_have_defaults);
if ~all(have_defaults)
    undef_fields=fields_needed(~have_defaults);
    if get(herbert_config,'log_level')>-1     
        for i=1:numel(undef_fields)
            disp(['RUNDATA:get_defaults:field: ',undef_fields{i},' is not among fields which have defaults']);
        end
    end
    error('RUNDATA:invalid_arguments','get_defaults: requested defaults for fields which do not have any defaults');
end

% return default values for the fields requested, sorted according to
% fields needed
default_values = get_def(this,fields_needed);

if numel(default_values)==1
    default_values=default_values{1};
end

function def=get_def(this,fields_needed)
% return default values for the fields requested
selection      = ismember(this.fields_have_defaults,fields_needed);
default_values = this.the_fields_defaults(selection);
default_keys   = this.fields_have_defaults(selection);
nf = numel(default_keys);
def   = cell(1,nf);
for i=1:nf    
    def{i}=default_values{ismember(default_keys,fields_needed{i})};
end



