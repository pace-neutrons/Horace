function set_pref_accessor_(obj,type,facc_name)
% method allows manually set preferable accessor for specific
% object type. New accessor will be used until sqw_formats_factory is
% loaded in memory and have not been updated.
% Inputs:
% obj     --  Instance of sqw_formats_factory
% type    --  name of the type, one wants to set accessor for.
% facc_name
%         -- name of file-accessor class to set as target for
%            the type provided. The name have to be among the
%            names of the registered accessors (classes present
%            in obj.supported_accessors_ list.
% Empty facc_name resets factory to default values.
%
% Returns:
% Modified sqw_formats_factory singleton with new file accessor
% set as default for input type.
% get_pref_access method invoked without parameters would also
% return the file accessor, specified as input of this method.

if ~ischar(type)||isstring(type)
    type = class(type);
end
if ~ischar(facc_name)||isstring(facc_name)
    facc_name = class(facc_name);
end
if isempty(facc_name)
    obj.types_map_ = containers.Map(obj.written_types_ ,...
        obj.access_to_type_ind_);
    obj.preferred_accessor_num_  = 1;
    return;
end

type_at = ismember(obj.written_types_,type);
if ~any(type_at)
    error('HORACE:sqw_fromats_factory:invalid_argument', ...
        'Type: %s is not among the types, factory know how to save',type)
end

known_types = cellfun(@class,obj.supported_accessors_,'UniformOutput',false);
facc_at = ismember(known_types,facc_name);
if ~any(facc_at)
    error('HORACE:sqw_fromats_factory:invalid_argument', ...
        'class: "%s" is not among the file accessors, registered with the factory',facc_name)
end
facc_idx = find(facc_at);
obj.preferred_accessor_num_ = facc_idx;
obj.types_map_(type) = facc_idx;