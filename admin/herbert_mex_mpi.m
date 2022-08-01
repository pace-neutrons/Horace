function [ok,mess] = herbert_mex_mpi(varargin)
% the script to build cpp communicator using Matlab compiler and not using
% cmake.
%
% Manually modify this script to specify the mpi libraries location in your
% system.
%
use_her_mpich = true;
verbose = nargin > 0;
pths = horace_paths;

% the files, contributing into the communicator.
input_files = {'cpp_communicator.cpp', 'input_parser.cpp', 'MPI_wrapper.cpp'};
% Dependency set-up part
opt_file = '';

if ispc()
    if use_her_mpich
        mpi_folder = fullfile(pths.low_level,'external','win64','MSMPI-8.0.12');
        mpi_hdrs_folder = fullfile(mpi_folder,'include');
        mpi_lib_folder = fullfile(mpi_folder,'lib');

    else
        % use Microsoft MPI, compatible with mpich
        mpi_folder = 'C:\programming\MS_MPI_sdk';
        mpi_lib_folder = fullfile(mpi_folder,'lib','x64');
        mpi_hdrs_folder = fullfile(mpi_folder,'include');
    end
    mpi_lib_2use ={'msmpi.lib'};
elseif isunix()
    if use_her_mpich
        % use MPICH
        %mpi_folder = '/usr/local/mpich/';
        mpi_folder = fullfile(pths.low_level,'external','glnxa64','mpich-3.3a2');
        mpi_hdrs_folder = fullfile(mpi_folder,'include');
        % .a also possible
        mpi_lib_2use = {'libmpi.so','libmpich.so','libmpicxx.so'};
    else
        %opt_file = fullfile(pths.admin, '_compiler_settings','Matlab2020a','mex_C++openmpi_glnxa64.xml');
        mpi_folder = '/usr/lib64/mpich-3.2/';
        mpi_hdrs_folder = '/usr/include/mpich-3.2-x86_64/';
        mpi_lib_2use = {'libmpicxx.so','libmpi.so'};
    end
    %mpi_folder = '/home/isis_direct_soft/mpich/';

    mpi_lib_folder = fullfile(mpi_folder,'lib');

else
    error('HERBERT_MEX_MPI:not_implemented',...
        'Mac build is not implemented. Use cmake');
end

% Executable part
ok = true;
mess = [];
mpi_lib = fullfile(mpi_lib_folder,mpi_lib_2use);

% code folder:
code_folder = fullfile(pths.low_level,'cpp','cpp_communicator');
input_files = fullfile(code_folder,input_files);

% additional include folder, containing mpich
add_include = ['-I',mpi_hdrs_folder];
if verbose
    add_include = {'-v',add_include};
else
    add_include = {add_include};
end
outdir = fullfile(pths.herbert,'DLL',['_',computer],'_R2015a');

build_version_h(pths.root)
try
    opt = sprintf('CXXFLAGS=$CFLAGS -fopenmp -std=c++11 -Wl,-rpath=%s,--enable-new-dtags,--no-undefined,-fopenmp',mpi_lib_folder);
    if isempty(opt_file)
        mex(add_include{:},opt,input_files{:},...
            mpi_lib{:},'-outdir',outdir);
    else
        mex(add_include{:},opt,input_files{:},...
            mpi_lib{:},'-f',opt_file,'-outdir',outdir);
    end
catch Err
    ok = false;
    mess = Err.message;
    disp(mess);
end
