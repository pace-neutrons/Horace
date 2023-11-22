function wout = split(w,varargin)
% Split an sqw object into an array of sqw objects, each made from a single spe data set
%
%   >> wout = split(w)
%
% Input:
% ------
%   w        --  Input sqw object
% Optional keys:
%  '-files'  -- if provided, return list of sqw files instead of sqw
%               objects. When split objects do not fit memory, they are all
%               stored in files and split returns list of the files.
%               When the option is provided,
%
% Output:
% -------
%   wout    Array of sqw objects, each one made from a single spe data file
%           If w is filebacked object, wout are filebacked too.
%
%           If their images do not fit to memory, wout would be the list of
%           filenames, containing these files.

nfiles = w.main_header.nfiles;

% Catch case of single contributing spe dataset
if nfiles == 1
    wout = w;
    return
end

%
% Evaluate the size of the resulting split to know what subalgorithm to use
%
%split_img_size = 3*numel(data.s)*8; % size of resulting split image
%split_pix_size = w.pix.num_pixels*PixelDataBase.pix_byte_size;
%
% This is partial implementation. Works only for pix in memory

page_op = PageOp_split_sqw();
page_op = page_op.init(w);
wout    = sqw.apply_op(w,page_op);
