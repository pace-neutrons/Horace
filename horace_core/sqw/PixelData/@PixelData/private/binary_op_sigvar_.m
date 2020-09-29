function pix_out = binary_op_sigvar_(obj, dnd_obj, binary_op, flip, npix)
%% BINARY_OP_SIGVAR_ perform a binary operation between this and a sigvar or
% sigvar-like object (e.g. dnd)
%
if nargout == 0
    pix_out = obj;
else
    pix_out = copy(obj);
end

dnd_size = sigvar_size(dnd_obj);
if ~isequal(dnd_size, [1, 1]) && ~isequal(dnd_size, size(npix))
    error('PIXELDATA:do_binary_op', ...
          ['dnd operand must have size [1,1] or size equal to the inputted ' ...
           'npix array.\nFound dnd size %s, and npix size %s'], ...
           iarray_to_matstr(dnd_size), iarray_to_matstr(size(npix)));
end

sigvar_pix = sigvar(obj.signal, obj.variance);

if ~isequal(size(npix), [1, 1])
    sigvar_dnd = sigvar(repelem(dnd_obj.s(:), npix(:))', ...
                        repelem(dnd_obj.e(:), npix(:))');
end

if flip
    res = binary_op(sigvar_dnd, sigvar_pix);
else
    res = binary_op(sigvar_pix, sigvar_dnd);
end

pix_out.signal = res.s;
pix_out.variance = res.e;
