function herbert_mex (varargin)
% Create mex files for all the Herbert fortran routines
%
%   >> herbert_mex                  % All mex functions
%   >> herbert_mex(source_code)     % Specific mex function e.g. >> herbert_mex ('rebin_1d_hist.for')
%   >> herbert_mex(...,'debug')     % Debug version of mex file

start_dir=pwd;
root_dir = fileparts(which(mfilename)); % root directory is assumed to be that in which this function resides

% Parse options
% -------------
if nargin==1 || nargin==2
    if strcmpi(varargin{end},'debug')
        debug=true;
    else
        debug=false;
    end
    if nargin==2 || (nargin==1 && ~debug)
        file=varargin{1};
    else
        file='';    % compile all
    end
elseif nargin==0
    debug=false;
    file='';
else
    error('Check number of input arguments')
end

% Get directories for library names and output mex file folder
% -------------------------------------------------------------
if strcmpi(computer,'PCWIN64')
    lib_dir='x64';  % parent folder for libraries for the present architecture
    mex_dir='x64';  % mex file parent folder name; should be same as lib_dir by convention
elseif strcmpi(computer,'PCWIN')
    lib_dir='Win32';
    mex_dir='Win32';
else
    error('Architecture type not supported yet')
end
    
   
try
%    cd(root_dir);
    
    if ~isempty(file)
        mgenie_mex_single(root_dir, mex_dir, lib_dir, file, debug);
        
    else
        mgenie_mex_single(root_dir, mex_dir, lib_dir, 'integrate_1d_points.for',debug');
        mgenie_mex_single(root_dir, mex_dir, lib_dir, 'rebin_1d_hist.for',debug');
        mgenie_mex_single(root_dir, mex_dir, lib_dir, 'rebin_1d_hist_by_descriptor.for',debug');
        mgenie_mex_single(root_dir, mex_dir, lib_dir, 'rebin_1d_hist_get_xarr.for',debug');

    end
    
    cd(start_dir);
    disp('Succesfully created all required mex files from fortran.')
catch
    disp('Problems creating mex files. Please try again.')
%    cd(start_dir);
end

%----------------------------------------------------------------
function mgenie_mex_single (root_dir, mex_dir, lib_dir, flname, debug)
% mex a single file

source_rel_dir = 'source_mex';          % relative directory of mex file source code
out_rel_dir = fullfile('mex',mex_dir);  % relative directory of compiled mex file
 
flname = fullfile(root_dir,source_rel_dir,flname);
outdir = fullfile(root_dir,out_rel_dir);

disp(['Mex file creation from ',flname,' ...'])
if ~debug
    lib = fullfile(root_dir,'projects','Herbert_lib',lib_dir,'release','Herbert_lib.lib');
    mex(flname, '-outdir', outdir, lib);
else
    lib = fullfile(root_dir,'projects','Herbert_lib',lib_dir,'debug','Herbert_lib.lib');
    mex(flname, '-g', '-outdir', outdir, lib);
end
