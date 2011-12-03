function herbert_mex_windows (varargin)
% Create mex files for all the Herbert fortran routines for Windows operating system
%
% Will place mex files in the folder \mex below this file. it is assumed that all the required libraries have
% previously been built. Installation requires a manual copy of the mex files to the relevant folder; this i smeant only
% as a useful utility function to create the mex files.
%
% During development:
% --------------------
%   >> herbert_mex_windows                  % Create all mex functions, release versions
%   >> herbert_mex_windows(source_file)     % Create specific mex function e.g. >> herbert_mex ('rebin_1d_hist') (assumed .for)
%
%   >> herbert_mex_windows('debug')             % Create debug versions of all mex files
%   >> herbert_mex_windows(source_file,'debug') % Create specific debug version of a mex file
% 
% Installation:
% ------------
% Clean the output mex folder and create the requested mex file or complete set of mex files
% Simply the same as herbert_mex or herbert_mex(source_file) with a clear beforehand to ensure no possible
% error of copying the wriong file(s).
%   >> herbert_mex_windows('install')               % Install release versions of all mex files in correct DLL folder
%   >> herbert_mex_windows(source_file,'install')   % Install a specific release version of a mex file in correct DLL folder
%
% Distinguishes between Windows 32 and Windows 64.

start_dir=pwd;
root_dir = fileparts(which(mfilename)); % root directory is assumed to be that in which this function resides

% Parse options
% -------------
if nargin==1 || nargin==2
    debug=false;
    install=false;
    if strcmpi(varargin{end},'debug')
        debug=true;
    elseif strcmpi(varargin{end},'install')
        install=true;
    end
    if nargin==2 || (nargin==1 && ~(debug||install))
        file=varargin{1};
    else
        file='';    % compile all
    end
elseif nargin==0
    debug=false;
    install=false;
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
    create_mex_files(root_dir, mex_dir, lib_dir, file, debug, install);
    cd(start_dir);
    disp('Succesfully created all required mex files from fortran.')
catch
    disp('Problems creating mex file(s). Please try again.')
end

%----------------------------------------------------------------
function create_mex_files (root_dir, mex_dir, lib_dir, flname, debug, install)
% mex a single file with extension .for, or all files in the 

source_rel_dir = 'source_mex';          % relative directory of mex file source code
out_rel_dir = fullfile('mex',mex_dir);  % relative directory of compiled mex file

outdir = fullfile(root_dir,out_rel_dir);

if install
    startdir=pwd;
    try
        cd(outdir)
        directory=dir('*.*');
        for i=1:numel(directory)
            if ~directory(i).isdir, delete(directory(i).name), end
        end
        cd(startdir)
    catch
        cd(startdir)
        error('Unable to clean out the mex folder')
    end
end
disp('DONE')

if ~isempty(flname)
    fort.name = fullfile(root_dir,source_rel_dir,[flname,'.for']);
else
    fort = dir(fullfile(root_dir,source_rel_dir,'*.for'));
    for i=1:numel(fort)
        fort(i).name=fullfile(root_dir,source_rel_dir,fort(i).name);   % add full path to name
    end
end

for i=1:numel(fort)
    if ~debug
        disp(['Mex file creation from ',fort(i).name,' ...'])
        lib = fullfile(root_dir,'projects','Herbert_lib',lib_dir,'release','Herbert_lib.lib');
        mex(fort(i).name, '-outdir', outdir, lib);
    else
        disp(['Mex file (debug version) creation from ',fort(i).name,' ...'])
        lib = fullfile(root_dir,'projects','Herbert_lib',lib_dir,'debug','Herbert_lib.lib');
        mex(fort(i).name, '-g', '-outdir', outdir, lib);
    end
end
