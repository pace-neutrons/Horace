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
%   pix_out     A PixelData object containing all the pixels in the inputted
%               PixelData objects
%               The type of the object (filebacked or
%               memory backed) will be defined by the size of the target
%               object. If the number of pixels in the 

% Take the class of the first object as the type of result.
if ~isa(varargin{1},'PixelDataBase')
    error('HORACE:PixelDataBase:invalid_argument', ...
        ['cat requested arguments are PixelDatBase sub-classes.' ...
        ' Class of the first input is: %s'], ...
        class(varargin{1}));
end
pix_out = copy(varargin{1});
if numel(varargin) == 1
    return;
end

page_op = PageOp_cat_pix();
page_op = page_op.init(varargin{:});
if page_op.npix_tot == 0 % pix_out already defined and it is empty
    return;
end
pix_out = PixelDataFileBacked.apply_op(pix_out,page_op);
