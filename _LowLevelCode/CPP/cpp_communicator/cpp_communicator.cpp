// hdf_mex_reader : Defines the exported functions for the DLL application.
//

#include "cpp_communicator.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	const char REVISION[] = "$Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)";
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
		work_type, data_address,data_tag, nbytes_to_transfer, data_buffer);

	n_workers = pCommunicatorHolder->class_ptr->numprocs;
	switch (work_type)
	{
	case(init_mpi):{
		pCommunicatorHolder->class_ptr->init();
	}
	case(labSend): {
		return;
	}
	case(labReceive): {
		return;
	}
	case(labProbe): {
		return;
	}
	case(close_mpi):{
		pCommunicatorHolder->clear_mex_locks();
		delete pCommunicatorHolder;


		for (int i = 0; i < nlhs; ++i) {
			plhs[i] = mxCreateNumericMatrix(0, 0, mxUINT64_CLASS, mxREAL);
		}
		return;
	}
	}

	if (nlhs > 1)
		plhs[(int)read_Outputs::mex_reader_handle] = pCommunicatorHolder->export_hanlder_toMatlab();

}
