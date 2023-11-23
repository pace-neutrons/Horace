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
%               When '-files' option is provided the split returns files
%               instead of objects in any situation.
%  '-filebacked'
%           -- if provided, request split object to be filebacked
%              regardless of
%
% Output:
% -------
%   wout    Array of sqw objects, each one made from a single spe data file
%           If w is filebacked object, wout are filebacked too.
%
%           If their images do not fit to memory, wout would be the list of
%           filenames, containing these files.

if numel(w)>1
    error('HORACE:split:not_implemented', ...
        'split currently works with only one sqw object');
end
[ok,mess,return_files,split_filebacked] = parse_char_options(varargin, ...
    {'-files','-filebacked'});
if ~ok
    error('HORACE:split:invalid_arguments',mess);
end

nfiles = w.main_header.nfiles;

% Catch case of single contributing spe dataset
if nfiles == 1
    wout = w;
    return
end

%
% Evaluate the size of the resulting split to know what subalgorithm to use
%
split_img_size = 3*numel(w.data.s)*8; % size of resulting split image
split_pix_size = w.pix.num_pixels*w.pix.pix_byte_size;
total_size = split_img_size + split_pix_size;
%
hpc = hpc_config;
mem_available = hpc.phys_mem_available;

page_op = PageOp_split_sqw();
if total_size > mem_available || split_filebacked % probably for tests
    if split_img_size<mem_available && ~return_files
        pix_filebacked = true;
    else
        error('HORACE:split:not_implemented', ...
            'split with partial images not fitting to memory is not yet implemented')
    end
else
    pix_filebacked = false;
end
page_op = page_op.init(w,pix_filebacked);
wout    = sqw.apply_op(w,page_op);
