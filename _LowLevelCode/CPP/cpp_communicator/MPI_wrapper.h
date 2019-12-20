#pragma once
#include <vector>
#include <list>
#include <cmath>
#include <mpi.h>

class iSendMessHolder {
public:
    MPI_Request* theRequest;
    std::vector<uint8_t> mess_body;
};

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
    // the list of assyncroneous messages, stored until delivered
    std::list<iSendMessHolder> assyncMessList;

};