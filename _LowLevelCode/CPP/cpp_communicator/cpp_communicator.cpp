#include "cpp_communicator.h"
/* The mex file provides media for MPI communications betwen various Horace workers. 

 Usage:

   varargout = cpp_communicator('operation',[Matlab_class_holder],varargin);
   where:
 --  'operation':   is the string, describing the operation, the communicator should perform.
                     majority of input and output parameters depends on  the operation

-- 	Matlab_class_holder: the value of the Matlab pointer to the MPI communicator. 
                         All operations except init needs this pointer to use initialized MPI framework. 
                         init operation creates and returns this pointer. 

The allowed operations and their parameters are:
*** 'init'  Initializes MPI framework to allow further MPI operations.
Inputs:  -- no other inputs accepted.
Outputs:
  1     -- pointer to  new intialized MPI framework.
  2     -- Index (number) of current MPI process
  3     -- size of the MPI pool current worker is the part of.

*** 'finalize'  Closes MPI framework and breaks all incomplete MPI communications. No further MPI communications
                allowed after this operation.
Inputs: -- Matlab_class_holder :: pointer to initialized C++ MPI framework wrapper used for interprocess communications
Outputs: -- empty matrix.

*** 'labIndex' Queries the number of the current parallel worker and the size of the MPI pool
Inputs: -- Matlab_class_holder :: pointer to initialized C++ MPI framework wrapper used for interprocess communications
Outputs: 
  1     -- pointer to current MPI framework.
  2     -- Index (number) of current MPI process
  3     -- size of the MPI pool current worker is the part of.
*/


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    //* Check and parce input  arguments. */
    char *data_buffer(nullptr);

    int data_address(0), data_tag(0);
    size_t n_workers;
    size_t nbytes_to_transfer;
    input_types work_type;


    class_handle<MPI_wrapper>* pCommunicatorHolder = parse_inputs(nlhs, nrhs, prhs,
        work_type, data_address, data_tag, nbytes_to_transfer, data_buffer);

    // avoid problem with multiple finalization
    if (pCommunicatorHolder == nullptr) { // this can happen only if close_mpi is selected and the framework had been already finalized
        if (nlhs > 0)
            plhs[(int)labIndex_Out::comm_ptr] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
        return;

    }

    n_workers = pCommunicatorHolder->class_ptr->numProcs;
    switch (work_type)
    {
    case(init_mpi): { // Initialize MPI communications and return labIndex and numLabs
        pCommunicatorHolder->class_ptr->init();
        n_workers = pCommunicatorHolder->class_ptr->numProcs;
        set_numlab_and_nlabs(pCommunicatorHolder, nlhs, plhs, nrhs, prhs);
        break;
    }
    case(labIndex): {  // return labindex and number of workers
        set_numlab_and_nlabs(pCommunicatorHolder, nlhs, plhs, nrhs, prhs);
        break;
    }
    case(labSend): {
        break;
    }
    case(labReceive): {
        break;
    }
    case(labProbe): {
        break;
    }
    case(close_mpi): {
        pCommunicatorHolder->clear_mex_locks();
        delete pCommunicatorHolder;

        for (int i = 0; i < nlhs; ++i) {
            plhs[i] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
        }
        return;
    } // end case
    } // end switch

     if (nlhs > 0)
         plhs[(int)labIndex_Out::comm_ptr] = pCommunicatorHolder->export_hanlder_toMatlab();

}
void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder,int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    if (nlhs >= (int)labIndex_Out::numLab + 1) {
        plhs[(int)labIndex_Out::numLab] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        uint64_t * pNlab = (uint64_t *)mxGetData(plhs[(int)labIndex_Out::numLab]);
        if (pCommunicatorHolder)
            *pNlab = (uint64_t)pCommunicatorHolder->class_ptr->labIndex+1;
        else
            *pNlab = 0;
    }
    if (nlhs == (int)labIndex_Out::n_workers + 1) {
        plhs[(int)labIndex_Out::n_workers] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        uint64_t * pNworkers = (uint64_t *)mxGetData(plhs[(int)labIndex_Out::n_workers]);
        if (pCommunicatorHolder)
            *pNworkers = (uint64_t)(uint64_t)pCommunicatorHolder->class_ptr->numProcs;
        else
            *pNworkers = 0;
    }

}
