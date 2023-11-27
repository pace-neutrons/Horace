function report_op_completed_(~,out_obj)
% print information about result of pageOp
% Inputs:
% obj      -- initialized pageOp
% out_obj  -- the object or array of objects produced by pageOp
if numel(out_obj) > 1
    fprintf(['*** %d resulting objects are backed by files:\n' ...
        '*** first: %s,\n*** last : %s\n'], ...
        numel(out_obj), ...
        out_obj(1).pix.full_filename, ...
        out_obj(end).pix.full_filename)
else
    if isa(out_obj,'sqw')
        out_file_name = out_obj.pix.full_filename;
    else
        out_file_name = out_obj.full_filename;
    end
    fprintf('*** Resulting object is backed by file: %s\n', ...
        out_file_name)
end
