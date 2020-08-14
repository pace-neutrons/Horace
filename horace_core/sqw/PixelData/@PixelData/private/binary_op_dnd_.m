function pix_out = binary_op_dnd_(obj, dnd_obj, binary_op, flip, npix)
%% BINARY_OP_DND_ perform a binary operation between this and a DnD object
%

dnd_size = sigvar_size(dnd_obj);
if ~isequal(dnd_size, [1, 1]) && ~isequal(dnd_size, size(npix))
    error('PIXELDATA:do_binary_op', ...
          ['err_msg']);
end
