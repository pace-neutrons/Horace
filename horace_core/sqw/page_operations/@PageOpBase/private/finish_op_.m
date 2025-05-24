function [out_obj,obj] = finish_op_(obj,in_obj)
% Finalize page operations.
%
% Contains common code to transfer data changed by operation to
% out_obj.   Need overloading for correct image calculations
% and specifics of particular operation
%
% Input:
% obj     -- instance of the page operations
% in_obj  -- sqw object-source of the operation
%
% Returns:
% out_obj -- sqw object created as the result of the operation
% obj     -- nullified PageOp object.

pix   = obj.pix_;
pix   = pix.set_data_range(obj.pix_data_range_);
% revert to usual way of performing pixel operations
% (data converted to double when accessed)
pix.keep_precision = false;

if ~(obj.inplace_ || obj.do_nopix_)
    % clear alignment (if any) as alignment has been applied during
    % page operation(s)
    pix   = pix.clear_alignment();
end

if isempty(obj.img_) % changes_pix_only -- would not work here
    % as some operations work on sqw but only modify pixels.
    pix = pix.finish_dump(obj);
    out_obj = pix.copy();
else
    if obj.do_nopix_
        out_obj = obj.img_;
    else
        out_obj = in_obj.copy();
        if obj.exp_modified
            out_obj.experiment_info = ...
                out_obj.experiment_info.get_subobj(obj.unique_run_id_);
        end
        out_obj.pix  = pix;
        % image should be modified by method overload.
        out_obj.data = obj.img_;
        out_obj = out_obj.finish_dump(obj);
        if ~out_obj.is_filebacked && obj.init_filebacked_output
            warning('HORACE:filebacked_ignored',['\n' ...
                '*** Input and output objects are placed in memory. Filebacked option is ignored.\n' ...
                '    Save the resulting object in sqw file\n' ...
                '    and open it in filebacked mode if you really need it filebacked.'])
        end
    end
end
obj.pix_  = PixelDataMemory();
obj.img_  = [];
obj.npix_ = [];
obj.write_handle_ = [];
