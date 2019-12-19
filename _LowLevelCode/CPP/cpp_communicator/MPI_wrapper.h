#pragma once
#include <vector>
#include <cmath>
#include <mpi.h>

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

    MPI_wrapper() :
        labIndex(-1), numProcs(0), isTested(false) {}
    int init(bool isTested = false);
    void close();
    void barrier();

    ~MPI_wrapper() {
        this->close();
    }
    // index of the current MPI lab (worker)
    int labIndex;
    // total  number of MPI labs (workers)
    int numProcs;
    // test mode used to run various test operations over MPI_wrapper in single process, 
    // when no real mpi exchange is initiated.
    bool isTested;
private:


};