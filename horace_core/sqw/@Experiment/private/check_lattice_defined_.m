function [obj,std_form] = check_lattice_defined_(obj,std_form)
% verify if lattice is already defined on experiment and if it is but is
% not defined in the new setter, set up lattice from the existing lattice

if ~obj.samples_set_ % not set, no further checks
    return;
end

% unique_objects used to save time scanning. Do not use to replace.
old_uni_obj = obj.samples_.expose_unique_objects();
old_lat_def = cellfun(@(x)~isempty(x.alatt),old_uni_obj);
old_ang_def = cellfun(@(x)~isempty(x.angdeg),old_uni_obj);
if any(old_lat_def) && any(old_ang_def)
    obj.old_lattice_holder_ = obj.samples_;    
end
