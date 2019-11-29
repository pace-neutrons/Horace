function [ok,mess] = herbert_mex_mpi(varargin)

input_files = {'cpp_communicator.cpp', 'input_parser.cpp', 'MPI_wrapper.cpp'};
mpich_folder = '/usr/local/mpich/';

ok = true;
mess = [];


her_folder = fileparts(which('herbert_init'));
code_folder = fullfile(her_folder,'_LowLevelCode','CPP','cpp_communicator');
input_files = cellfun(@(fn)fullfile(code_folder,fn),input_files,'UniformOutput',false);

add_include = ['-I',mpich_folder,'include'];
add_lib = ['-L',mpich_folder,'lib'];

outdir = fullfile(her_folder,'DLL','_GLNXA64','_R2015a');
%mex('-lut','CXXFLAGS=$CFLAGS -fopenmp -std=c++11','LDFLAGS= -pthread -Wl,--no-undefined  -fopenmp',add_files{:}, '-outdir', outdir);
try 
    mex(input_files{:},add_include,add_lib,'-v','-l:libmpi.so.12 -lmpich -lmpicxx',...
        '-outdir',outdir);
catch Err
    ok = false; 
    mess = Err.message;
end