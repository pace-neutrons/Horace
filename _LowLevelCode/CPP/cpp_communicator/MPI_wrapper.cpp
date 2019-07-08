#include "MPI_wrapper.h"
#include "input_parser.h"

int MPI_wrapper::init() {
	int *argc(nullptr);
	char*** argv(nullptr);

	auto err = MPI_Init(argc, argv);
	if (err != MPI_SUCCESS) {
		throw_error("MPI_MEX_COMMUNICATOR:runtime_error", 
			"Can not initialize MPI framework");
	}

	MPI_Comm_size(MPI_COMM_WORLD, &this->numProcs);
	MPI_Comm_rank(MPI_COMM_WORLD, &this->labIndex);

	return 0;
}
void MPI_wrapper::close() {
	MPI_Finalize();
}
