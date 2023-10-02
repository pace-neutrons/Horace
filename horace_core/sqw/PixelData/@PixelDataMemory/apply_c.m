function sqw_out = apply_c(sqw_in,page_op)
% Apply unary operation affecting pixels and image over the input sqw
% object
%
%
% Inputs:
% obj    --  PixelDataMemory object
% sqw_in --  sqw object which contains this pixel object (if it contains
%            other pixel object, that object will be destroyed.
%            Valid sqw  object requested, i.e. obj.data.npix define the
%            location of pixels in memory
%page_op --  The instance of the PageOpBase class, which perform operation
%            over pixels and image of the SQW object
% Output:
% sqw_out -- sqw_in object, modified using the operation provided as input
%
[page_op,page_data] = page_op.apply_op(sqw_in.data.npix);
page_op = page_op.common_page_op(page_data);
sqw_out = page_op.finish_op(sqw_in);