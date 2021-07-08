#!/bin/sh
# iDAaaS specific batch script to run mpi job. 
# The specific is in used MPI version and the way to set it up
#
# modify it according to your system to be able to find matlab and mpi (mpich)
# or compile cpp_communicator to use Herbert own mpich, ensuring Slurm cluster manager 
# understands it and can use pmi to control mpi job
#
# The environment variables set up by Matlab for this worker to run
#

module load mpi/mpich-3.2-x86_64
#
# Set up additional Matlab files search path, containing horace_on/herbert_on 
# initialization scripts and Matlab worker script ($PARALLEL_WORKER value),
# run by Matlab when it runs in the script mode
export MATLABPATH='/usr/local/mprogs/Users/':$MATLABPATH
#--------------------------------------------------------------------------------------
# WILL be modified by SlurmWrapper init function according to the particular job settings
#
# HERBERT_PARALLEL_EXECUTOR -- the program which executes the parallel job on server. Usually Matlab
export HERBERT_PARALLEL_EXECUTOR='matlab'
# HERBERT_PARALLEL_WORKER -- the parameters string used as input arguments for the parallel job. If its Matlab, 
# it is the worker name and the run parameters. If PARALLEL_EXECUTOR is compiled Matlab job,
# the string may be empty
export HERBERT_PARALLEL_WORKER='-batch worker_v2'
# WORKER_CONTROL_STRING -- the base64 encoded string, which defines location of the common for MPI workers
# communication folder
export WORKER_CONTROL_STRING=''
# The variable enables progress logs writing in parallel workers
export DO_PARALLEL_MATLAB_LOGGING='false'
#---------------------------------------------------------------
# DEBUGGER help variables:
#hostname
#echo "PARALLEL_EXECUTOR: ${HERBERT_PARALLEL_EXECUTOR}"
#
#echo "PARALLEL_WORKER: ${HERBERT_PARALLEL_WORKER}"
# 
#echo "WORKER_CONTROL_STRING: ${WORKER_CONTROL_STRING}"
#
#echo "DO_PARALLEL_MATLAB_LOGGING: ${DO_PARALLEL_MATLAB_LOGGING}"
#---------------------------------------------------------------
# Combine and run the parallel task:
CMD="\"${PARALLEL_EXECUTOR}\" \"${HERBERT_PARALLEL_WORKER}\" "
#
#echo "COMMAND TO RUN:  ${CMD}"
#
eval $CMD
#
EXIT_CODE=${?}
echo "Exiting with code: ${EXIT_CODE}"
exit ${EXIT_CODE}

