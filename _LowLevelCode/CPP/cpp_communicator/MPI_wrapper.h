#pragma once
#include <vector>
#include <cmath>
#include <mpi.h>

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

	MPI_wrapper():
        labIndex(-1), numProcs(0){}
	int init();
	void close();

	~MPI_wrapper() {
		this->close();
	}

	int labIndex;  // index of the current MPI lab (worker)
	int numProcs; // total  number of MPI labs (workers)
private:


};