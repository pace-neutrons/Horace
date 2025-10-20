#include "cpp_communicator.h"
#include "../utility/version.h"


/* The mex file provides media for MPI communications betwen various Horace workers.

 Usage:

   varargout = cpp_communicator('operation',[Matlab_class_holder],varargin);
   where:
 --  'operation':   is the string, describing the operation, the communicator should perform.
                     majority of input and output parameters depends on  the operation

 -- Matlab_class_holder: the value of the Matlab pointer to the MPI communicator.
                         All operations except init test_init needs this pointer to use initialized MPI framework.
                         init operation creates and returns this pointer.

The allowed operations and their parameters are:

*** 'init'  Initializes MPI framework to allow further MPI operations.
Inputs:  -- optional,
  2     --  length of asynchronous messages queue. The framework fails if this length is exceeded.
  3     --  data_messages_tag: the tag of the channel, used to transmit blocking messages. Default is 8
  4     -- interrupt_messages_tag: the tag of the channel used to transmit interrupt messages. Default is 100
  5     -- Ignored in this mode. In test mode its 2-element array, containing labIndex and numLabs for cluster under investigation.


Outputs:
  1     -- pointer to  new initialized MPI framework.
  2     -- Index (number) of current MPI process
  3     -- size of the MPI pool current worker is the part of.

*** 'init_test_mode'  Initializes MPI wrapper with fake MPI values, which run within a single process.
Inputs:
  2     -- length of asynchronous messages queue. The framework fails if this length is exceeded.
  3     -- data_messages_tag: the tag of the channel, used to transmit blocking messages. Default is 8
  4     -- interrupt_messages_tag: the tag of the channel used to transmit interrupt messages. Default is 100
  5     -- in test mode 2-element array, containing labIndex and numLabs for cluster under investigation.
           Ignored in production mode.

Outputs:
  1     -- pointer to  fake MPI framework.
  2     -- Index (number) of current MPI process:             always 1
  3     -- size of the MPI pool current worker is the part of: always 1

*** "labSend"  executes MPI send operation:
Inputs:
  1  -- mode_name  -- the string 'labSend' identifies send mode
  2  -- pointer to the initialized MPI framework,
  3  -- dest_id address (number) of the worker who should receive the message
  4  -- tag -- the message tag (id)
  5  -- is_synchronous -- should message be send synchronously or asynchronously.
  6  -- pointer to Matlab array, containing serialized message body
  7  -- large_data_buffer optional (for synchronous messages) -- the pointer to Matlab structure, containing large data.
Outputs:
  1     -- pointer to  new the MPI framework, performing send operation

*** "labReceive"  executes MPI receive operation:
Inputs:
  1  -- mode_name  -- the string 'labReceive' identifies receive mode
  2  -- pointer to the initialized MPI framework,
  3  -- source_id address (number) of the worker who should send the message (-1 -- any address)
  4  -- tag -- the message tag (id) to receive (-1 -- any tag)
  5  -- is_synchronous -- should message be received synchronously (blocking operation until received) or
        asynchronously (return nothing if no message present).
Outputs:
  1 -- pointer to  new the MPI framework, performing asynchronous operation
  2 -- pointer to Matlab array, containing serialized message body
  3 -- optional (for synchronous messages) -- the pointer to Matlab cellarray containing large data -- not yet implemented
  4 -- optional -- pointer to the 2-element array containing real source address and source tag for the message, been received

*** "labProbe"  executes asynchronous MPI_Iprobe operation
Inputs:
  1  -- mode_name  -- the string 'labProbe' identifies labprobe mode
  2  -- pointer to MPI initialized framework,
  3  -- dest_id address (number) of the worker which is asked for message
  4  -- tag -- the message tag (id) or array of message tags to ask for
Outputs:
  1     -- pointer to  new the MPI framework, performing asynchronous operation
  2     -- 2-elements array with address and tag of the first existing message present in the queue
           satisfying the requests or empty matrix if no message is present

*** "clearAll"  -- receive and ignore all messages, intended for this worker
  1  -- mode_name  -- the string 'clearAll', which identifies this mode
  2  -- pointer to MPI initialized framework.
Outputs: -- pointer to the initialized framework


*** 'finalize'  Closes MPI framework and breaks all incomplete MPI communications. No further MPI communications
                allowed after this operation.
Inputs:
 1 --  mode_name           :: the string 'finalize' identifying the mode
 2 --  Matlab_class_holder :: pointer to initialized C++ MPI framework wrapper used for interprocess communications
Outputs: -- empty matrix.

*** 'labIndex' Queries the number of the current parallel worker and the size of the MPI pool
Inputs:
    -- Matlab_class_holder :: pointer to initialized C++ MPI framework wrapper used for interprocess communications
Outputs:
  1     -- pointer to current real or fake MPI framework.
  2     -- Index (number) of current MPI process
  3     -- size of the MPI pool current worker is the part of.
*/

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }

    // pointer to the class responsible for data exchange
    class_handle<MPI_wrapper>* mpi_comm_ptr(nullptr);

    //* Check and parse input  arguments. */
    uint8_t* data_buffer(nullptr);

    std::vector<int32_t> data_addresses;
    std::vector<int32_t> data_tag;
    bool is_synchronous(false);

    InitParamHolder InitPar;
    size_t nbytes_to_transfer;

    input_types work_type = parse_inputs(nlhs, nrhs, prhs,
        mpi_comm_ptr, data_addresses, data_tag, is_synchronous,
        data_buffer, nbytes_to_transfer, InitPar);

    // avoid problem with multiple finalization
    if (mpi_comm_ptr == nullptr) { // this can happen only if close_mpi is selected and the framework had been already finalized
        if (nlhs > 0)
            plhs[(int)labIndex_Out::comm_ptr] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
        return;
    }

    switch (work_type) {
    case (init_mpi): { // Initialize MPI communications and return labIndex and numLabs
        mpi_comm_ptr->class_ptr->init(InitPar);
        set_numlab_and_nlabs(mpi_comm_ptr, nlhs, plhs, nrhs, prhs);
        break;
    }
    case (init_test_mode): {
        // init test mode providing init parameters as input to init function
        mpi_comm_ptr->class_ptr->init(InitPar);
        set_numlab_and_nlabs(mpi_comm_ptr, nlhs, plhs, nrhs, prhs);
        break;
    }
    case (labIndex): { // return labIndex and number of workers
        set_numlab_and_nlabs(mpi_comm_ptr, nlhs, plhs, nrhs, prhs);
        break;
    }
    case (labBarrier): { // wait at barrier. Should not return anything
        mpi_comm_ptr->class_ptr->barrier();
        return;
    }
    case (labSend): {
        mpi_comm_ptr->class_ptr->labSend(data_addresses[0], data_tag[0], is_synchronous, data_buffer, nbytes_to_transfer);
        break;
    }
    case (labReceive): {
        mpi_comm_ptr->class_ptr->labReceive(data_addresses[0], data_tag[0], is_synchronous, plhs, nlhs);
        break;
    }
    case (labProbe): {
        std::vector<int32_t> address_present, tag_present;
        mpi_comm_ptr->class_ptr->labProbe(data_addresses, data_tag, address_present, tag_present);
        size_t n_present = address_present.size();
        if (n_present == 0) {
            plhs[(int)labProbe_Out::addr_tag_array] = mxCreateNumericMatrix(1, 0, mxINT32_CLASS, mxREAL);
        } else {
            plhs[(int)labProbe_Out::addr_tag_array] = mxCreateNumericMatrix(2, n_present, mxINT32_CLASS, mxREAL);
            int32_t* pAddrTag = (int32_t*)mxGetData(plhs[(int)labProbe_Out::addr_tag_array]);
            for (size_t i = 0; i < n_present; i++) {
                pAddrTag[2 * i + 0] = address_present[i] + 1;
                pAddrTag[2 * i + 1] = tag_present[i];
            }
        }
        break;
    }
    case (clearAll): { // receive and discard all messages, directed to the framework
        mpi_comm_ptr->class_ptr->clearAll();
        break;
    }
    case (close_mpi): {
        mpi_comm_ptr->clear_mex_locks();
        delete mpi_comm_ptr;
        mpi_comm_ptr = nullptr; // only needed for static variable

        for (int i = 0; i < nlhs; ++i) {
            plhs[i] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
        }
        return;
    } // end case
    } // end switch

    if (nlhs > 0) {
        plhs[(int)labIndex_Out::comm_ptr] = mpi_comm_ptr->export_hanlder_toMatlab();
    }
}
/* If appropriate number of output arguments are available, set up the mex routine output arguments to mpi_numLab and mpi_labNum values
   extracted from initialized MPI framework.
*/
void set_numlab_and_nlabs(class_handle<MPI_wrapper>* const pCommunicatorHolder, int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

    if (nlhs >= (int)labIndex_Out::numLab + 1) { // return labIndex
        plhs[(int)labIndex_Out::numLab] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
        uint64_t* pNlab = (uint64_t*)mxGetData(plhs[(int)labIndex_Out::numLab]);
        if (pCommunicatorHolder) {
            *pNlab = (uint64_t)pCommunicatorHolder->class_ptr->labIndex + 1;
        } else {
            *pNlab = 0;
        }
    }
    if (nlhs >= (int)labIndex_Out::n_workers + 1) { // also return NumLabs
        plhs[(int)labIndex_Out::n_workers] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
        uint64_t* pNworkers = (uint64_t*)mxGetData(plhs[(int)labIndex_Out::n_workers]);
        if (pCommunicatorHolder) {
            *pNworkers = (uint64_t)pCommunicatorHolder->class_ptr->numLabs;
        } else {
            *pNworkers = 0;
        }
    }
    if (nlhs == (int)labIndex_Out::MAX_N_Outputs) { // also return the names of the pool nodes
        if (!pCommunicatorHolder) {
            plhs[(int)labIndex_Out::pool_names] = mxCreateCellMatrix(0, 1);
            return;
        }
        auto nLabs = pCommunicatorHolder->class_ptr->numLabs;
        auto pNames = mxCreateCellMatrix(nLabs, 1);
        plhs[(int)labIndex_Out::pool_names] = pNames;
        for (auto i = 0; i < nLabs; i++) {
            mxSetCell(pNames, i, mxCreateString(pCommunicatorHolder->class_ptr->node_names[i].c_str()));
        }
    }
}
#undef CLASS_HANDLE_SIGNATURE
