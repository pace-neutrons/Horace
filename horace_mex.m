function horace_mex
% Usage:
% horace_mex;
% Create mex files for all the Horace fortran and C(++) routines
% assuming that proper mex file compilers are configured for Matlab
%
% to configure a gcc compiler (version >= 4.3 requested)  to produce omp
% code one have to edit  ~/.matlab/mexoptions.sh file and add -fopenmp key 
% to the proprer compiler and linker keys
% $Revision: $ ($Date: $)

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('horace_mex'));
    cd(rootpath);

    fortran_in_rel_dir = ['LowLevelCode',filesep,'intel',filesep];
    cpp_in_rel_dir = ['LowLevelCode',filesep,'cpp',filesep];
    out_rel_dir = ['@sqw',filesep,'private'];
    
    mex_single([cpp_in_rel_dir 'accumulate_cut_c/accumulate_cut_c'], out_rel_dir,'accumulate_cut_c.cpp');
    mex_single([cpp_in_rel_dir 'bin_pixels_c/bin_pixels_c'], out_rel_dir,'bin_pixels_c.cpp');    
    mex_single([cpp_in_rel_dir 'calc_projections_c/calc_projections_c'], out_rel_dir,'calc_projections_c.cpp');
    mex_single([cpp_in_rel_dir 'sort_pixels_by_bins/sort_pixels_by_bins'], out_rel_dir,'sort_pixels_by_bins.cpp');
    mex_single([fortran_in_rel_dir 'get_spe_fortran/get_spe_fortran'], out_rel_dir,'get_spe_fortran.F','IIget_spe_fortran.F');
    mex_single([fortran_in_rel_dir], out_rel_dir,'get_par_fortran.F','IIget_par_fortran.f');
    mex_single(fortran_in_rel_dir, out_rel_dir,'get_phx_fortran.f','IIget_phx_fortran.f');

    cd(start_dir);
    disp('Succesfully created all required mex files from fortran and C++')
catch
    disp('Problems creating mex files. Please try again manually.')
    cd(start_dir);
end

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
    error(' mex_single request at leas one file name to process');
end
nCells   = 2*(nargin-2)-1;
add_files=cell(nCells,1);
add_fNames=cell(nCells,1);
outdir = fullfile(curr_dir,out_rel_dir);
for i=1:nCells
    if((i/2-floor(i/2))>0) % fractional part
        add_files{i} = fullfile(curr_dir,in_rel_dir,varargin{floor(i/2)+1});
        add_fNames{i}=varargin{floor(i/2)+1};
    else
        add_files{i}  = ' ';
        add_fNames{i} = ' ';
    end
end
flname =  cell2str(add_files);
short_fname = cell2str(add_fNames);

disp(['Mex file creation from ',short_fname,' ...'])
mex(flname, '-outdir', outdir);
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

