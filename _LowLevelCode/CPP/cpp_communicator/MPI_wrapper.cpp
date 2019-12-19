#include "MPI_wrapper.h"
#include "input_parser.h"

int MPI_wrapper::init(bool isTested) {
    int* argc(nullptr);
    char*** argv(nullptr);
    int err(-1);
    if (isTested) {
        // set up test values and return without initializeing the framework
        this->isTested = true;
        this->numProcs = 1;
        this->labIndex = 0;
        return 0;
    }
    try {
        err = MPI_Init(argc, argv);
    }
    catch (...) {}

    if (err != MPI_SUCCESS) {
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
            "Can not initialize MPI framework");
    }

    MPI_Comm_size(MPI_COMM_WORLD, &this->numProcs);
    MPI_Comm_rank(MPI_COMM_WORLD, &this->labIndex);

    return 0;
}
void MPI_wrapper::close() {
    if (this->isTested) {
        // nthing to close in test mode
        return;
    }
    MPI_Finalize();
}
void MPI_wrapper::barrier() {
    if (this->isTested) {
        // no barrier as only one local client can be tested
        return;
    }

    MPI_Barrier(MPI_COMM_WORLD);
}
