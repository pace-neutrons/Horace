function [ok,mess] = herbert_mex_mpi(varargin)
% the script to build cpp communicator using Matlab compiler and not using
% cmake. 
% 
% one needs to manually modify this script to specify the mpi libraries 
% location in the system. 
%

input_files = {'cpp_communicator.cpp', 'input_parser.cpp', 'MPI_wrapper.cpp'};

if ispc()
    % let's use Microsof MPI, compartible with mpich
    mpi_folder = 'C:\programming\MS_MPI_sdk';    
    mpi_lib_folder = fullfile(mpi_folder,'lib','x64');
    headers_folder    = fullfile(mpi_folder,'include');
    mpi_lib_string ='msmpi.lib';
    mpi_lib = {fullfile(mpi_lib_folder,mpi_lib_string)};
elseif isunix()
    % let's use MPICH
    mpi_folder = '/usr/local/mpich/';
    headers_folder    = fullfile(mpi_folder,'include');        
    mpi_lib_folder = fullfile(mpi_folder,'lib');

    mpi_lib_string ={'libmpi','libmpich','libmpicxx'};
    mpi_lib = cellfun(@(x)fullfile(mpi_lib_folder,x),mpi_lib_string,...
        'UniformOutput',false);
    %configure_unix_compiler(mpi_folder,headers_folder,mpi_lib_folder, mpi_lib_string);
else
    error('HERBERT_MEX_MPI:not_implemented',...
        'Mac build is not implemented. Use cmake');
end

ok = true;
mess = [];

% code folder:
her_folder = herbert_root();
code_folder = fullfile(her_folder,'_LowLevelCode','CPP','cpp_communicator');
input_files = cellfun(@(fn)fullfile(code_folder,fn),input_files,'UniformOutput',false);

add_include = ['-I',headers_folder];
add_lib =['-L',mpi_lib_folder ];      %,['-rpath',mpich_lib]};

outdir = fullfile(her_folder,'herbert_core','DLL',['_',computer],'_R2015a');

try 
    mex('-v',add_include,input_files{:},...
        mpi_lib{:},'-outdir',outdir);
catch Err
    ok = false; 
    mess = Err.message;
end

function configure_unix_compiler(mpi_folder,headers_folder,mpi_lib_folder,mpi_lib_string)