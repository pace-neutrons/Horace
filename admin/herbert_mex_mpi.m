function [ok,mess] = herbert_mex_mpi(varargin)

input_files = {'cpp_communicator.cpp', 'input_parser.cpp', 'MPI_wrapper.cpp'};
mpich_folder = '/usr/local/mpich/';

ok = true;
mess = [];


her_folder = herbert_root();
code_folder = fullfile(her_folder,'_LowLevelCode','CPP','cpp_communicator');
input_files = cellfun(@(fn)fullfile(code_folder,fn),input_files,'UniformOutput',false);

add_include = ['-I',mpich_folder,'include'];
mpich_lib = fullfile(mpich_folder,'lib');
add_lib =['-L',mpich_lib ]; %,['--rpath-link=',mpich_lib]};

outdir = fullfile(her_folder,'herbert_core','DLL','_GLNXA64','_R2015a');
%mex('-lut','CXXFLAGS=$CFLAGS -fopenmp -std=c++11','LDFLAGS= -pthread -Wl,--no-undefined  -fopenmp',add_files{:}, '-outdir', outdir);
try 
    mex('-v',add_include,...
        add_lib,'-lmpi','-lmpich','-lmpicxx',['-Wl,-rpath-link,',mpich_lib],input_files{:},'-outdir',outdir);
catch Err
    ok = false; 
    mess = Err.message;
end