#!/bin/sh
# iDAaaS specific butch script to run mpi job. 
# modify it according to your system to be able to find matlab and mpi (mpich)
# or compile cpp_communicator to use Herbert own mpich
#
# The enviroment variables set up by Matlab for this worker to run
#

module load mpi/mpich-3.2-x86_64
#
# Set up additional Matlab files searh path, containing horace_on/herbert_on 
# initialization scripts and matlab worker script ($PARALLEL_WORKER value),
# run by Matlab when it runs in the script mode
export MATLABPATH='/usr/local/mprogs/Users/'
#
# WILL be modified by SlurmWrapper init finction according to the particular job settings
#
# MATLAB_PARALLEL_EXECUTOR -- the program which executes the parallel job on server. Usually matlab
export MATLAB_PARALLEL_EXECUTOR='matlab'
# PARALLEL_WORKER -- the parameters string used as input arguments for the Matlab job. If its Matlab, 
# it is the worker name and the run parameters. If its compiled Matlab job, the string may be empty
export PARALLEL_WORKER='-batch worker_v2'
# WORKER_CONTROL_STRING -- the base64 encoded string, which defines location of the common for MPI workers
# communication folder
export WORKER_CONTROL_STRING=''
#---------------------------------------------------------------
# DEBUGGER help variables:
#hostname
#echo "MATLAB_PARALLEL_EXECUTOR: ${MATLAB_PARALLEL_EXECUTOR}"
#
#echo "PARALLEL_WORKER: ${PARALLEL_WORKER}"
# 
#echo "WORKER_CONTROL_STRING: ${WORKER_CONTROL_STRING}"
#
CMD="\"${MATLAB_PARALLEL_EXECUTOR}\" \"${PARALLEL_WORKER}\" "
#
#echo "COMMAND TO RUN:  ${CMD}"
#
eval $CMD
#
EXIT_CODE=${?}
echo "Exiting with code: ${EXIT_CODE}"
exit ${EXIT_CODE}

