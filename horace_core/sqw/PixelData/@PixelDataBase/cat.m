function pix_out = cat(varargin)
% Concatenate the given PixelData objects' pixels. This function performs
% a straight-forward data concatenation.
%
%   >> joined_pix = pix_data1.cat(pix_data1, pix_data2);
%
% Input:
% ------
%   varargin    A cell array of PixelData objects
%
% Output:
% -------
%   obj         A PixelData object containing all the pixels in the inputted
%               PixelData objects
%               The type of the object (filebacked or
%               memorybacked) will be defined by the type of
%               the first object to cat.

% Take the dataclass of the first object.
if isempty(varargin)
    pix_out = obj;
    return;
end
pix_out = copy(obj);
page_op = PageOp_cat_pix();
page_op = page_op.init(varargin{:});
pix_out = PixelDataFileBacked.apply_op(pix_out,page_op);
