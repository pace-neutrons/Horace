function horace_mex
% Usage:
% horace_mex;
% Create mex files for all the Horace C(++) routines assuming that proper mex
% file compilers are configured for Matlab
%
% to configure a gcc compiler (version >= 4.3 requested)  to produce omp
% code one have to edit  ~/.matlab/mexoptions.sh file and add -fopenmp key
% to the proper compiler and linker keys


start_dir=pwd;
C_compiled=false;
pths = horace_paths;
root_dir = pths.root;

% build package version
build_version_h(root_dir)

% check OS for hdf compilation purpose
if ispc
    hdf_ext = '_win';
elseif isunix
    hdf_ext = '_unix';
elseif ismac
    hdf_ext = '_unix';
    warning('HORACE_MEX:not_implemented',...
        'MAC compilation is not implemented. Trying with Unix settings which probably would not work');
end
% settings for compiling hdf routines
[ma,me,mi]=H5.get_libversion();
hdf_version = ma+0.1*me+0.001*mi;
build_hdf_reader= true;
if hdf_version == 1.812
    hdf_root_dir = fullfile(pths.low_level,'external',['HDF5_1.8.12',hdf_ext]);
elseif hdf_version == 1.806
    hdf_root_dir = fullfile(pths.low_level,'external',['HDF5_1.8.6',hdf_ext]);
else
    build_hdf_reader = false;
    warning('HORACE_MEX:not_implemented',...
        ['Matlab uses %d.%d.%d version of HDF library. ',...
        'HDF mex code is provided for HDF 1.8.12 and 1.8.6 versions only.',...
        ' You need to download appropriate hdf headers yourseld and modify horace_mex to use your version'],...
        ma,me,mi);
end
% lib directirues:
%arc = computer('arch');
%lib_dir = fullfile(matlabroot,'bin',arc);

try % mex C++
    disp('**********> Creating mex files from C++ code')
    % root directory is assumed to be that in which this function resides
    cd(root_dir);

    cpp_in_rel_dir = ['_LowLevelCode',filesep,'cpp',filesep];
    % get folder names corresponding to the current Matlab version and OS
    [VerFolderName, ~, OSdirname] = matlab_version_folder();
    if ispc
        out_rel_dir = fullfile('horace_core','DLL',OSdirname);
        out_hdf_dir = fullfile('horace_core','DLL',OSdirname,VerFolderName);
    else %Unix
        out_rel_dir = fullfile('horace_core','DLL',OSdirname,VerFolderName);
        out_hdf_dir = out_rel_dir;
    end

    if(~exist(out_rel_dir,'dir'))
        mkdir(out_rel_dir);
    end
    % simple OMP routines
    % build C++ files
    mex_single(fullfile(cpp_in_rel_dir,'get_ascii_file'), out_rel_dir,...
        'get_ascii_file.cpp','IIget_ascii_file.cpp')
    mex_single(fullfile(cpp_in_rel_dir,'serialiser'), out_rel_dir,...
        'c_serialize.cpp')
    mex_single(fullfile(cpp_in_rel_dir,'serialiser'), out_rel_dir,...
        'c_deserialize.cpp')
    mex_single(fullfile(cpp_in_rel_dir,'serialiser'), out_rel_dir,...
        'c_serial_size.cpp')


    mex_single([cpp_in_rel_dir 'accumulate_cut_c'], out_rel_dir, ...
        'accumulate_cut_c.cpp');
    mex_single([cpp_in_rel_dir 'bin_pixels_c'], out_rel_dir, ...
        'bin_pixels_c.cpp');
    mex_single([cpp_in_rel_dir 'calc_projections_c'], out_rel_dir, ...
        'calc_projections_c.cpp');
    mex_single([cpp_in_rel_dir 'sort_pixels_by_bins'], out_rel_dir, ...
        'sort_pixels_by_bins.cpp');
    mex_single([cpp_in_rel_dir 'mtimesx_horace'], out_rel_dir, ...
        'mtimesx_mex.cpp');
    mex_single([cpp_in_rel_dir 'compute_pix_sums'], out_rel_dir, ...
        'compute_pix_sums_c.cpp','compute_pix_sums_helpers.cpp');


    % create the procedured to access hdf files
    if build_hdf_reader
        cof = {'hdf_mex_reader.cpp','hdf_pix_accessor.cpp','input_parser.cpp',...
            'pix_block_processor.cpp'};
        mex_hdf([cpp_in_rel_dir 'hdf_mex_reader'], out_hdf_dir,hdf_root_dir,cof{:} );
    end

    disp('**********> Successfully created required mex files from C++')
    C_compiled=true;
    add_version_folder(out_rel_dir);
catch ME
    warning('HORACE:horace_mex:no_mex', 'Can not create C++ mex files, reason: %s. Please try to do it manually.',ME.message);

end
try
    cof = {'combine_sqw.cpp','exchange_buffer.cpp','fileParameters.cpp',...
        'pix_mem_map.cpp', 'sqw_pix_writer.cpp', 'sqw_reader.cpp', 'nsqw_pix_reader.cpp'};
    mex_single([cpp_in_rel_dir 'combine_sqw'], out_rel_dir,cof{:} );
    disp('**********> Successfully created mex file for combining components from C++')
catch ME
    warning('HORACE:horace_mex:no_mex', 'Can not create C++ combining procedure, reason: %s. Combining using C++ is not available',ME.message);
end

cd(start_dir);
if C_compiled
    set(hor_config,'use_mex',true);
end

function add_version_folder(out_rel_dir)
% Add folder with compiled mex files to Matlab search path
%
%hor_folder = fileparts(which('horace_init.m'));
root_folder = fileparts(fileparts(mfilename('fullpath')));
mex_folder    = fullfile(root_folder,out_rel_dir);
addpath(mex_folder);

function mex_hdf (in_rel_dir, out_rel_dir,hdf_root, varargin)
% Usage:
% mex_single (in_rel_dir, out_rel_dir,hdf_root, varargin)
%
% Inputs:
% in_rel_dir -- the folder where hdf code is located vrt. the current
%               folder
% out_rel_dir -- the folder where target files should be placed vrt. to the
%                current folder
% hdf_root    -- the path to the
% mex a set of files to produce a single mex file, the file with the mex
% function has to be first in the  list of the files to compile
%

curr_dir = pwd;
if(nargin<1)
    error('MEX_SINGLE:invalid_arg',' request at leas one file name to process');
end
fnames = varargin(:);
nFiles   = numel(fnames); % files go in varargin
add_fNames = cellfun(@(x)[x,' '],fnames,'UniformOutput',false);
add_files  = cellfun(@(x)(fullfile(curr_dir,in_rel_dir,x)),fnames,'UniformOutput',false);
outdir = fullfile(curr_dir,out_rel_dir);

short_fname = cell2str(add_fNames{1});
disp(['Mex file creation from ',short_fname,' ...'])

if ~check_access(outdir,add_files{1})
    error('MEX_SINGLE:invalid_arg',' can not get write access to new mex file: %s',fullfile(outdir,add_files{1}));
end
hdf_include = fullfile(hdf_root,'include');
if ispc
    hdf_lib = fullfile(hdf_root,'lib');
else
    arc = computer('arch');
    matlab_root = find_matlab_path();
    hdf_lib     = fullfile(matlab_root,arc);
end
mex(['-I',hdf_include],['-L',hdf_lib],'-lhdf5','-lhdf5_hl',add_files{:}, '-outdir', outdir);




%%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, varargin)
% Usage:
% mex_single (in_rel_dir, out_rel_dir, varargin)
%
% mex a set of files to produce a single mex file, the file with the mex
% function has to be first in the  list of the files to compile

fprintf('**** compiling: %s\n',varargin{1})
curr_dir = pwd;
if(nargin<1)
    error('MEX_SINGLE:invalid_arg',' request at leas one file name to process');
end
fnames = varargin(:);
nFiles   = numel(fnames);% files go in varargin
add_fNames = cellfun(@(x)[x,' '],fnames,'UniformOutput',false);
add_files  = cellfun(@(x)(fullfile(curr_dir,in_rel_dir,x)),fnames,'UniformOutput',false);
outdir = fullfile(curr_dir,out_rel_dir);

short_fname = cell2str(add_fNames{1});
disp(['Mex file creation from ',short_fname,' ...'])

if ~check_access(outdir,add_files{1})
    error('MEX_SINGLE:invalid_arg',' can not get write access to new mex file: %s',fullfile(outdir,add_files{1}));
end
if ispc
    cxx_flags = 'COMPFLAGS= $COMPFLAGS /openmp';
    ld_flags = 'LDFLAGS= --no-undefined';
else
    cxx_flags = 'CXXFLAGS= $CFLAGS  -fopenmp -std=c++11';
    ld_flags  = 'LDFLAGS= -pthread -Wl,--no-undefined  -fopenmp';
end
if(nFiles==1)
    fname      = strtrim(add_files{1});
    %cxx_flags = "
    mex(cxx_flags,ld_flags,fname, '-outdir', outdir);
else
    %mex('-g',add_files{:}, '-outdir', outdir);
    mex('-lut',cxx_flags,ld_flags,add_files{:}, '-outdir', outdir);
end

function access =check_access(outdir,filename)

[~, sfname] = fileparts(filename);
fname = fullfile(outdir,[sfname,'.',mexext()]);

if exist(fname,'file')
    try
        delete(fname);
        access = true;
    catch
        access = false;
    end
else
    h=fopen(fname,'w+');
    if h<3
        access = false;
    else
        if fclose(h)~=0
            error('MEX_SINGLE:invalid_arg',' can not close opened test file: %s',fname);
        end
        delete(fname);
        access = true;
    end
end


%%
function str = cell2str(c)
%CELL2STR Convert cell array into evaluable string.
%
%   See also MAT2STR

if ~iscell(c)

    if ischar(c)
        str = c;
    elseif isnumeric(c)
        str = mat2str(c);
    else
        error('HORACE:horace_mex:invalid_argument', 'Illegal array in input.')
    end

else

    if isempty(c)
        str = '';
    else
        if ~all(ischar(c))
            error('HORACE:horace_mex:invalid_argument', 'Char cell array required');
        end
        str = cell2mat(c);
    end

end
