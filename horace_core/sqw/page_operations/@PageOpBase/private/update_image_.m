function obj = update_image_(obj,sig_acc,var_acc,npix_acc)
% UPDATE_IMAGE_ The piece of code which often but not always used at the end
% of an operation when modified data get transformed from
% accumulators to the final image.
% Inputs:
% sig_acc -- array accumulating changed signal during
%            operation(s)
% var_acc -- array accumulating changed variance during
%            operation(s)
% Optional:
% npix_acc -- array accumulating changes in npix during
%             operation(s)
% Returns:
% obj      -- operation object containing modified image, if
%             image have been indeed modified

[calc_sig,calc_var] = normalize_signal( ...
    sig_acc(:),var_acc(:),npix_acc(:));

sz = obj.img_.axes.dims_as_ssize;
img = obj.img_;
img.do_check_combo_arg = false;

img.s    = reshape(calc_sig,sz);
img.npix = reshape(npix_acc,sz);
if isempty(var_acc)
    img.e    = zeros(sz);
else
    img.e    = reshape(calc_var,sz);
end


img.do_check_combo_arg = true;
img = img.check_combo_arg();
obj.img_ = img;
