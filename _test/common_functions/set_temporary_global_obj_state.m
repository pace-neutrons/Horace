function cleanup_handle = set_temporary_global_obj_state(varargin)
% SET_TEMPORARY_GLOBAL_OBJ_STATE stores contents of current global memory
% to restore all objects in memory when cleanup option is invoked.
%
% Use it to avoid side effects from tests, which generate large number of
% unique objects in memory

% >> cleanup_handle = set_temporary_global_obj_state();
%
%WARNING: Temporary procedure. Should be unnecessary and removed when
%         proper object release at dereferences is implemented

mem_contents = struct();
mem_contents.inst = unique_obj_store.instance().get_objects('IX_inst');
mem_contents.samp = unique_obj_store.instance().get_objects('IX_samp');
mem_contents.det  = unique_obj_store.instance().get_objects('IX_detector_array');

%unique_obj_store.instance().clear('IX_inst');
%unique_obj_store.instance().clear('IX_samp');
%unique_obj_store.instance().clear('IX_detector_array');

cleanup_handle = onCleanup(@() restore(mem_contents));

end

function restore(mem_contents)
unique_obj_store.instance().clear('IX_inst');
unique_obj_store.instance().clear('IX_samp');
unique_obj_store.instance().clear('IX_detector_array');

unique_obj_store.instance().set_objects(mem_contents.inst);
unique_obj_store.instance().set_objects(mem_contents.samp);
unique_obj_store.instance().set_objects(mem_contents.det);


end
