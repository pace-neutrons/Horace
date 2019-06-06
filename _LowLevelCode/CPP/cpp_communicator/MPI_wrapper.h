#pragma once
#include <vector>
#include <cmath>
#include <mpi.h>

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

	MPI_wrapper() {}
	int init();
	void close();

	~MPI_wrapper() {
		this->close();
	}

	int myid, numprocs;
private:


};