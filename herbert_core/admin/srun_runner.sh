#!/bin/sh
# The enviroment variables set up by Matlab for this worker to run
#
# MATLAB_PARALLEL_EXECUTOR -- the program which executes the parallel job on server. Usually matlab
# PARALLEL_EXECUTOR_PARAMS -- the parameters string used as input arguments for the job
module load mpi/mpich-3.2-x86_64
#
hostname
echo "MATLAB_PARALLEL_EXECUTOR: ${MATLAB_PARALLEL_EXECUTOR}"
#
echo "PARALLEL_WORKER: ${PARALLEL_WORKER}"

# 
echo "WORKER_CONTROL_STRING: ${WORKER_CONTROL_STRING}"
#
CMD="\"${MATLAB_PARALLEL_EXECUTOR}\" \"${PARALLEL_EXECUTOR_PARAMS}\" "
#
echo "COMMAND TO RUN:  ${CMD}"
echo $CMD
#
eval $CMD
#
EXIT_CODE=${?}
echo "Exiting with code: ${EXIT_CODE}"
exit ${EXIT_CODE}

