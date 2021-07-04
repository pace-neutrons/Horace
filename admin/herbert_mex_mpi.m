function [ok,mess] = herbert_mex_mpi(varargin)
% the script to build cpp communicator using Matlab compiler and not using
% cmake.
%
% Manually modify this script to specify the mpi libraries location in your
% system.
%
use_her_mpich = false;
if nargin > 0
    verbouse = true;
else
    verbouse = false;
end
% the files, contributing into the communicator.
input_files = {'cpp_communicator.cpp', 'input_parser.cpp', 'MPI_wrapper.cpp'};
% Dependency set-up part
if ispc()
    % let's use Microsof MPI, compartible with mpich
    mpi_folder = 'C:\programming\MS_MPI_sdk';
    mpi_lib_folder = fullfile(mpi_folder,'lib','x64');
    mpi_hdrs_folder    = fullfile(mpi_folder,'include');
    mpi_lib_2use ={'msmpi.lib'};
elseif isunix()
    if use_her_mpich
        opt_file = '';
        % let's use MPICH
        %mpi_folder = '/usr/local/mpich/';
        mpi_folder = fullfile(herbert_root(), '_LowLevelCode/external/glnxa64/mpich-3.3a2/');
        mpi_hdrs_folder    = fullfile(mpi_folder,'include');
        % .a also possible
        mpi_lib_2use ={'libmpi.so','libmpich.so','libmpicxx.so'};
    else
        %opt_file = fullfile(herbert_root(),'admin/_compiler_settings/Matlab2020a/mex_C++openmpi_glnxa64.xml');
        opt_file = '';
        mpi_folder = '/usr/lib64/mpich-3.2/';
        mpi_hdrs_folder='/usr/include/mpich-3.2-x86_64/';
        mpi_lib_2use ={'libmpicxx.so','libmpi.so'};
    end
    %mpi_folder = '/home/isis_direct_soft/mpich/';
    
    mpi_lib_folder = fullfile(mpi_folder,'lib');
    %
else
    error('HERBERT_MEX_MPI:not_implemented',...
        'Mac build is not implemented. Use cmake');
end
% Executable part
ok = true;
mess = [];
mpi_lib = cellfun(@(x)fullfile(mpi_lib_folder,x),mpi_lib_2use,...
    'UniformOutput',false);


% code folder:
her_folder = herbert_root();
code_folder = fullfile(her_folder,'_LowLevelCode','cpp','cpp_communicator');
input_files = cellfun(@(fn)fullfile(code_folder,fn),input_files,'UniformOutput',false);

% additional include folder, containing mpich
add_include = ['-I',mpi_hdrs_folder];
if verbouse
    add_include = {'-v',add_include};
else
    add_include = {add_include};
end
outdir = fullfile(her_folder,'herbert_core','DLL',['_',computer],'_R2015a');

build_version_h(her_folder)
try
    % -Wl,-rpath,to_libmpi.so should be provided here for linux clusters but Matlab 2020a
    % does not support this option.
    if isempty(opt_file)
        mex(add_include{:},input_files{:},...
            mpi_lib{:},'-outdir',outdir);
    else
        mex(add_include{:},input_files{:},...
            mpi_lib{:},'-f',opt_file,'-outdir',outdir);
        
    end
catch Err
    ok = false;
    mess = Err.message;
    disp(mess);
end
