function report_on_target_files_(~,out_obj)
% print information about result of pageOp
% Inputs:
% obj      -- initialized pageOp
% out_obj  -- the object  produced by pageOp
if isa(out_obj,'sqw')
    out_file_name = out_obj.pix.full_filename;
else
    out_file_name = out_obj.full_filename;
end
fprintf('*** Resulting object is backed by file: %s\n', ...
    out_file_name)
