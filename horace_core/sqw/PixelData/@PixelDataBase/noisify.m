function pix_out = noisify(obj, varargin)
%=========================================================================
% This is a method of the PixelData class.
% It is called from the noisify(sqw_object,[options]) function to allow
% the noisify functionality to be applied on a per-page basis to the
% sqw object's pixel data.
% See noisify(sqw_object,...) for details of the input and the
% Herbert noisify function for details of how the input is used.
% This noisify adds random noise to the object's signal array, and a fixed
% error bar to the variance array, paging as required. The options in
% varargin specify how that is done; see the above functions for details.
% For options where the signal absolute maximum is used in the noise
% scaling, a paged pre-scan of the signal provides the maximum over all
% pages.
%
% Input:
% -----
% obj         The PixelData instance.
% data        (Optional) DnD to recompute on the fly
% varargs     Options for random number distribution and noise magnitude
%             scaling.
%
% Output:
% ------
% pix_out     If specified, returns a "noisified" copy of the input data
%             Otherwise it is a reference to the input object, which is
%             "noisified" in place.
%=========================================================================

% Output specification determines object copying behaviour.
% Only perform the operation on a copy if a return argument exists,
% otherwise perform the operation on obj itself.
pix_out = copy(obj);

pix_op = PageOp_mask();
if ~isempty(npix)
    pix_op.npix = npix;
end
pix_op    = pix_op.init(pix_out ,varargin{:});
if ~pix_op.noisify_par.is_poisson
    if ~pix_out.is_range_valid('signal')
        % Other options than Poisson require the signal maximum.
        % As we are paging, we need to get the overall max signal out of pix_out
        % before applying noisify to the individual pages.
        pix_out = pix_out.finalize_alignment();
    else
        range = pix_out.data_range;
        max_sig = range(2,pix_out.field_index('signal'));
    end
    pix_op.noisify_par.ymax = max_sig;
end
pix_out   = pix_out.apply_op(pix_op);

