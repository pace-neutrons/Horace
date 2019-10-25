function default_values =get_defaults(this,varargin)
% method returns default values, defined by default fields of
% the class
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%

if nargin==1
    fields_needed=this.fields_with_defaults();
else
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
end


%n_fields = numel(fields_needed);
%has_defaults=bool(zeros(n_fields,1));
%default_values=cell(n_fields,1);


check_def= @(field_name)check_default(this,field_name);
[has_defaults,default_values] = cellfun(check_def,fields_needed,'UniformOutput',false);
has_defaults = cellfun(@(x)(x~=0),has_defaults);

default_values=default_values(has_defaults);
if nargin>1
    
    undef_fields = fields_needed(~has_defaults);
    n_undef=numel(undef_fields);
    if n_undef>0
        if get(herbert_config,'log_level')>-1
            for i=1:n_undef
                disp(['RUNDATA:get_defaults:field: ',undef_fields{i},' is not among fields which have defaults']);
            end
        end
        error('RUNDATA:invalid_arguments','get_defaults: requested defaults for fields which do not have any defaults');
    end
end


function [has_default,default_val]=check_default(rundata_def,field_name)

try
    default_val = rundata_def.(field_name);
catch
    try
        default_val = rundata_def.lattice.(field_name);
    catch
        default_val =[];
        has_default = false;
        return;
    end
end

has_default = true;

