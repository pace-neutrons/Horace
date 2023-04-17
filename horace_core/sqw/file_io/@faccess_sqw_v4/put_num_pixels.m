function obj = put_num_pixels(obj, num_pixels)
%PUT_RAW_PIX  Store num_pixels in the appropriate position of the pixel data
%block.
%
% Inputs:
% obj -- initialized f-accessor object, containing proper block allocation
%        table with defined pixels block (containing correct number of pixels
%        to be in the target file and number of pixel rows (9, nothing else was tested))
%
% num_pixels -- Number of pixels to set
%

pdb = obj.bat_.blocks_list{end};
pdb.npixels = num_pixels;
pdb.put_data_header(obj.file_id_);

obj.bat_.blocks_list{end} = pdb;

end
