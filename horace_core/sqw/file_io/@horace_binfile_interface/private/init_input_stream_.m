function obj = init_input_stream_(obj,objinit)
% initialize object to read input file using proper obj_init
% information
%
% objinit information is obtained by can_load method if the
% file indeed can be loaded by the selected loader
%


if ~objinit.defined() && obj.faccess_version ~=0
     error('HORACE:horace_binfile_interface',...
         'attempt to initalize f-accessor using undefined objinit information')
end
obj.file_id_ = objinit.file_id;
obj.num_dim_ = objinit.num_dim;
obj.file_closer_ = onCleanup(@()fclose(obj));


