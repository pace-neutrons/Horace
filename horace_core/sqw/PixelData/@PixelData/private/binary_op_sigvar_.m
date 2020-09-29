function pix_out = binary_op_sigvar_(obj, dnd_obj, binary_op, flip, npix)
%% BINARY_OP_SIGVAR_ perform a binary operation between this and a sigvar or
% sigvar-like object (e.g. dnd)
%
validate_inputs(obj, dnd_obj, npix);

if nargout == 0
    pix_out = obj;
else
    pix_out = copy(obj);
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

end

% -----------------------------------------------------------------------------
function validate_inputs(pix, dnd_obj, npix)
    dnd_size = sigvar_size(dnd_obj);
    if ~isequal(dnd_size, [1, 1]) && ~isequal(dnd_size, size(npix))
        error('PIXELDATA:do_binary_op', ...
            ['dnd operand must have size [1,1] or size equal to the inputted ' ...
            'npix array.\nFound dnd size %s, and npix size %s'], ...
            iarray_to_matstr(dnd_size), iarray_to_matstr(size(npix)));
    end

    npix_sum = sum(npix(:));
    if npix_sum ~= pix.num_pixels
        error('PIXELDATA:binary_op_sigvar_', ...
            ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
            'equal to the number of pixels in the PixelData object.\n' ...
            'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
            npix_sum, pix.num_pixels);
    end
end
