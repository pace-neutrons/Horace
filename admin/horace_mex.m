function horace_mex
% Usage:
% horace_mex;
% Create mex files for all the Horace Fortran and C(++) routines
% assuming that proper mex file compilers are configured for Matlab
%
% to configure a gcc compiler (version >= 4.3 requested)  to produce omp
% code one have to edit  ~/.matlab/mexoptions.sh file and add -fopenmp key
% to the proper compiler and linker keys
%
% $Revision$ ($Date$)
%

start_dir=pwd;
C_compiled=false;
try % mex C++
    disp('**********> Creating mex files from C++ code')
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('horace_init'));
    cd(rootpath);
    
    fortran_in_rel_dir = ['_LowLevelCode',filesep,'intel',filesep];
    cpp_in_rel_dir = ['_LowLevelCode',filesep,'cpp',filesep];
    % get folder names corresponding to the current Matlab version and OS
    [VerFolderName,versionDLLextention,OSdirname]=matlab_version_folder();
    out_rel_dir = ['DLL',filesep,OSdirname,filesep,VerFolderName];
    if(~exist(out_rel_dir,'dir'))
        mkdir(out_rel_dir);
    end
    
    mex_single([cpp_in_rel_dir 'accumulate_cut_c/accumulate_cut_c'], out_rel_dir,'accumulate_cut_c.cpp');
    mex_single([cpp_in_rel_dir 'bin_pixels_c/bin_pixels_c'], out_rel_dir,'bin_pixels_c.cpp');
    mex_single([cpp_in_rel_dir 'calc_projections_c/calc_projections_c'], out_rel_dir,'calc_projections_c.cpp');
    mex_single([cpp_in_rel_dir 'sort_pixels_by_bins/sort_pixels_by_bins'], out_rel_dir,'sort_pixels_by_bins.cpp');
    mex_single([cpp_in_rel_dir 'recompute_bin_data'], out_rel_dir,'recompute_bin_data_c.cpp');
    mex_single([cpp_in_rel_dir 'mtimesx_horace'], out_rel_dir,'mtimesx_mex.cpp');    

    
    disp('**********> Successfully created required mex files from C++')
    C_compiled=true;
    add_version_foloder(out_rel_dir);
catch ME
    message=ME.message;
    warning('**********> Can not create C++ mex files, reason: %s. Please try to do it manually.',message);
    
end
try
   cof = {'combine_sqw.cpp','exchange_buffer.cpp','fileParameters.cpp',...
       'pix_mem_map.cpp', 'sqw_pix_writer.cpp', 'sqw_reader.cpp', 'nsqw_pix_reader.cpp'};
   mex_single([cpp_in_rel_dir 'combine_sqw'], out_rel_dir,cof{:} );
   disp('**********> Successfully created mex file for combining components from C++')   
catch ME
    message=ME.message;
    warning('**********> Can not create C++ combining procedure, reason: %s. combining using C++ is not availile',message);   
end
%
F_compiled=false;
try  % mex FORTRAN
    disp('**********> Creating mex files from FORTRAN code')
    %    mex_single(fortran_in_rel_dir, out_rel_dir,'get_par_fortran.F','IIget_par_fortran.f');
    %    mex_single(fortran_in_rel_dir, out_rel_dir,'get_phx_fortran.f','IIget_phx_fortran.f');
    %    mex_single([fortran_in_rel_dir 'get_spe_fortran' filesep 'get_spe_fortran'], out_rel_dir,'get_spe_fortran.F','IIget_spe_fortran.F');
    %
    %    disp('**********> Successfully created all requested mex files from FORTRAN')
    disp('**********> No FORTRAN functions used at the moment')
    F_compiled=true;
catch ME
    message=ME.message;
    warning('**********> Can not create FORTRAN mex files, reason: %s Please try to do it manually.',message);
end
cd(start_dir);
if C_compiled && F_compiled
    set(hor_config,'use_mex',true);
end

function add_version_foloder(out_rel_dir)
% Add folder with compiled mex files to Matlab search path
%
hor_folder = fileparts(which('horace_init.m'));
mex_folder = fullfile(hor_folder,out_rel_dir);
addpath(mex_folder);




%%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, varargin)
% Usage:
% mex_single (in_rel_dir, out_rel_dir, varargin)
%
% mex a set of files to produce a single mex file, the file with the mex
% function has to be first in the  list of the files to compile
%

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
if(nFiles==1)
    fname      = strtrim(add_files{1});
    mex(fname, '-outdir', outdir);
else  
    %mex('-g',add_files{:}, '-outdir', outdir);
    mex(add_files{:}, '-outdir', outdir);    
end

function access =check_access(outdir,filename)

[spath,sfname] = fileparts(filename);
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
        error('Illegal array in input.')
    end
    
else
    
    N = length(c);
    if N > 0
        if ischar(c{1})
            str = c{1};
            for ii=2:N
                if ~ischar(c{ii})
                    error('Inconsistent cell array');
                end
                str = [str,c{ii}];
            end
        else
            error(' char cells requested');
        end
    else
        str = '';
    end
    
end

function copy_get_ascii_to_herbert()
% function copies get_ascii_file to herbert executable as it is currently
% the same exec.

her_path = fileparts(which('herbert_init.m'));
hor_path = fileparts(which('horace_init.m'));
[matlab_dirname,dll_extention,os_dirname] = matlab_version_folder();

ascii_reader = ['get_ascii_file','.',dll_extention];
her_dll_targ = fullfile(her_path,'DLL',os_dirname,matlab_dirname);
hor_dll_sourc= fullfile(hor_path,'DLL',os_dirname,matlab_dirname);

copyfile(fullfile(hor_dll_sourc,ascii_reader),fullfile(her_dll_targ,ascii_reader),'f');

