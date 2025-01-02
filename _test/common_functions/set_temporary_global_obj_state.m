function cleanup_handle = set_temporary_global_obj_state(varargin)
% SET_TEMPORARY_GLOBAL_OBJ_STATE stores contents of current global memory
% to restore all objects in memory when cleanup option is invoked.
%
% Use it to avoid side effects from tests, which generate large number of
% unique objects in memory

% >> cleanup_handle = set_temporary_global_obj_state();
%

mem_contents = struct();
mem_contents.inst = unique_obj_store.instance().get_objects('IX_inst');
mem_contents.samp = unique_obj_store.instance().get_objects('IX_samp');
mem_contents.det  = unique_obj_store.instance().get_objects('IX_detector_arrays');

unique_obj_store.instance().clear('IX_inst');
unique_obj_store.instance().clear('IX_samp');
unique_obj_store.instance().clear('IX_detector_arrays');

cleanup_handle = onCleanup(@() restore(mem_contents));
% stop changes from being stored on disk.
config_instance.saveable = false;

for i = 1:2:numel(varargin)
    config_field = varargin{i};
    value = varargin{i + 1};
    config_instance.(config_field) = value;
end

end

function restore(mem_contents)
unique_obj_store.instance().clear('IX_inst');
unique_obj_store.instance().clear('IX_samp');
unique_obj_store.instance().clear('IX_detector_arrays');

unique_obj_store.instance().set_objects(mem_contents.inst);
unique_obj_store.instance().set_objects(mem_contents.samp);
unique_obj_store.instance().set_objects(mem_contents.det);


end
