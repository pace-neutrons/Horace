function obj_out = apply_c(obj_in,page_op)
% Apply unary operation affecting pixels and image over the input sqw
% object
%
%
% Inputs:
% obj    --  PixelDataMemory object
% obj_in --  sqw object which contains this pixel object (if it contains
%            other pixel object, that object will be destroyed.
%            Valid sqw  object requested, i.e. obj.data.npix define the
%            location of pixels in memory
%  Or
%            PixelData object to oprate on
%page_op --  The instance of the PageOpBase class, which perform operation
%            over pixels and image of the SQW object
% Output:
% sqw_out -- sqw_in object, modified using the operation provided as input
%

npix = page_op.npix;

page_op = page_op.apply_op(npix,[1;numel(npix)]);
page_op = page_op.common_page_op();
%
obj_out = page_op.finish_op(obj_in);