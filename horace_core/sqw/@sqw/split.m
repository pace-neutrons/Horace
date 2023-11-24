function wout = split(w,varargin)
% Split an sqw object into an array of sqw objects, each made from a
% single spe or nxspe data set
%
%   >> wout = split(w)
%
% Input:
% ------
%   w        --  Input sqw object
% Optional:
%  folder_for_parts
%            --  The string contains full path to the folder where to place
%                sqw files representing parts of the sqw file to split.
%                If absent the files will be placed in working directory.
%
%                If operation perfomed in memory only, this path is ignored.
%                If this folder is provided, the resulting files are
%                assumed permanent files, so are not getting deleted when
%                their correspondent sqw objects are getting deleted from
%                memory.
% Optional keys:
%  '-files'  -- if provided, return list of sqw files instead of sqw
%               objects. When split objects do not fit memory, they are all
%               stored in files and split returns list of the files.
%               When '-files' option is provided the split returns files
%               instead of objects in any situation.
%  '-filebacked'
%           -- if provided, request split object to be filebacked
%              regardless of the possibility to place them in memory.
%              If split object' images do not fit memory, this option
%              is ignored and the code behaves as if option '-files' is
%              specified.
%
% Output:
% -------
%   wout    Array of sqw objects, each one made from a single spe data file
%
%           If all images from split files do not fit memory, wout would be
%           the list of filenames, referring to sqw files with contents of
%           the split objects.
% NOTE:
% if results is filebacked or list of files, the resulting files or files-bases
% for filebacked objects are placed in the 'folder_for_parts' directory or in
% working directory if 'folder_for_path' is not provided.
% The names of partial files are build from the name of the original sqw
% file with added suffix containing corresponding run_id.
% 
% For example: If you have initial sqw file Fe400mEv.sqw containing runs
% 32400,32401 and 32402 and split it in filebacked mode, the folder
% provided to keep result would contain files Fe400mEv_runID0032400.sqw,
% Fe400mEv_runID0032401.sqw and Fe400mEv_runID0032402.sqw

if numel(w)>1
    error('HORACE:split:not_implemented', ...
        'split currently works with only one sqw object');
end
[ok,mess,return_files,split_filebacked,argi] = parse_char_options(varargin, ...
    {'-files','-filebacked'});
if ~ok
    error('HORACE:split:invalid_arguments',mess);
end
if ~isempty(argi)
    folder_for_parts = argi{1};
    if ~isfolder(folder_for_parts)
        [ok,msg]=mkdir(folder_for_parts);
        if ~ok
            error('HORACE:split:invalid_argument', ...
                'folder %s does not exist and can not be created. Reason: %s', ...
                folder_for_parts,msg)
        end
    end
else
    folder_for_parts  = '';
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

% set keep_precision to false as filebacked operations here will be
% performed without change in precision.
w.pix.keep_precision = true;
split_pix_size = w.pix.num_pixels*w.pix.pix_byte_size;
total_size = split_img_size + split_pix_size;
%
hpc = hpc_config;
mem_available = hpc.phys_mem_available;


page_op = PageOp_split_sqw();
try
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
catch ME
    disp('**** total_size:')    
    disp(total_size)
    disp('**** mem_available:')        
    disp(total_size)    
    disp('**** split_filebacked:')            
    disp(split_filebacked)
    disp(ME.getReport());
    rethrow(ME);
end
page_op.outfile = folder_for_parts;
page_op = page_op.init(w,pix_filebacked);
wout    = sqw.apply_op(w,page_op);
