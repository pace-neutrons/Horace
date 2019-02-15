#include<string>
#include<iostream>
#include<cmath>
#include "mex.h"
#include "matrix.h"
#include <omp.h>


template <typename R, typename T> R * safealloc(const T d){
	R *out = nullptr;
	out = new R[d](); // R[d] does not initialize to zero. R[d]() does!
	if (out == 0) mexErrMsgIdAndTxt("HORACE:safealloc:allocation", "out of memory");
	return out;
}

template <typename T, typename R> T cell_idx_one(const T d, const T *cell, const T *span, const R *X, const R *minX, const R *delX, const R bin_shift){
	T idx=T(0); // the (output) linear index
	R tR=R(0);
	for (T i=0; i<d; i++){
		tR = (X[i]-minX[i])/delX[i] + bin_shift; // abstract floating point number
		if (tR > 0) { // no need to add to the linear index if this is negative (and out of bounds)
			// and we need to protect against floor(tR)+1>[number of bins along this direction]
			idx += ( tR >= cell[i] ) ? (cell[i]-T(1))*span[i] : T(tR)*span[i];
		}
	}
	return idx;
}
template <typename T, typename R> void cell_idx_chunk(const T d, const T *cell, const T *span, const T start, const T stop, const R *X, const R *minX, const R *delX, const R bin_shift, T *idx){
	for (T i=start; i<stop; i++)
		idx[i] = cell_idx_one(d,cell,span,X+i*d,minX,delX,bin_shift);
}
template <typename T, typename R> void cell_idx_chunk_once(const T d, const T *cell, const T *span, const T start, const T stop, const R *X, const R *minX, const R *delX, const R bin_shift, T *idx){
	R tR; // per-chunk temporary variable for calculating the index
	for (T j=start; j<stop; j++){
		for (T i=0; i<d; i++){
			tR = (X[j*d+i]-minX[i])/delX[i] + bin_shift; // abstract floating point number
			if (tR > 0) { // no need to add to the linear index if this is negative (and out of bounds)
				// and we need to protect against floor(tR)+1>[number of bins along this direction]
				idx[j] += ( tR >= cell[i] ) ? (cell[i]-T(1))*span[i] : T(tR)*span[i];
			}
		}
	}
}
template <typename T, typename R> void cell_idx(const int nthreads, const T d, const T *cell, const T *span, const T n, const R *X, const R *minX, const R *delX, const R bin_shift, T *idx){
	T chunk = n/nthreads;
	if (chunk<1||nthreads==1)
		cell_idx_chunk_once(d,cell,span,T(0),n,X,minX,delX,bin_shift,idx);
	else{
		T *offset = safealloc<T>(nthreads+1);
		for (T i=1; i<nthreads; i++) offset[i]=i*chunk; offset[nthreads]=n;
#pragma omp parallel firstprivate(d,bin_shift) shared(offset,cell,span,X,minX,delX,idx)
		{
			T tt = omp_get_thread_num();
			cell_idx_chunk_once(d,cell,span,offset[tt],offset[tt+1],X,minX,delX,bin_shift,idx);
		}
	}
}


using intType = mwSize;
// The gateway function which MATLAB can call directly
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	int nthreads = omp_get_max_threads();
	omp_set_num_threads(nthreads);
	// printf("Maximum OpenMP threads %d. We're using %d threads\n",nthreads,omp_get_num_threads());
	if (nrhs == 0){
//	test_everything();
	return;
	}
	
	
	// check number of inputs and outputs
	if (nrhs != 7) mexErrMsgIdAndTxt("HORACE:cell_idx:nrhs", "Seven input aruments expected.");
	if (nlhs != 1) mexErrMsgIdAndTxt("HORACE:cell_idx:nlhs", "One output argument required.");
	// check input types
	mxClassID iic = mxGetClassID(prhs[0]);
	if (mxGetClassID(prhs[1]) != iic) mexErrMsgIdAndTxt("HORACE:cell_idx:intType", "all integer inputs should be of the same type");
	if (mxGetClassID(prhs[6]) != iic) mexErrMsgIdAndTxt("HORACE:cell_idx:intType", "all integer inputs should be of the same type");

	if (!mxIsScalar(prhs[5])) mexErrMsgIdAndTxt("HORACE:cell_idx:notScalar", "The bin shift must be scalar");
	if (!mxIsScalar(prhs[6])) mexErrMsgIdAndTxt("HORACE:cell_idx:notScalar", "The indexing offset must be scalar");

	int dblinpt[4] = {2,3,4,5};
	for (int i=0; i<4; i++){
		if (!mxIsDouble(prhs[dblinpt[i]])||mxIsComplex(prhs[dblinpt[i]]))
			mexErrMsgIdAndTxt("Horace:cell_idx:notDouble","Expected real double input.");
	}

	// Make sure inputs have consistent sizes:
	intType dim, num;
	dim = intType( mxGetM(prhs[0]) ); // size(cell,1);
	num = intType( mxGetN(prhs[2]) ); // prod( size(X, 2:end) );
	if (mxGetM(prhs[2])!=dim)
		mexErrMsgIdAndTxt("Horace:cell_idx:dimensions","Inconsistent dimensionality");
	int dbyone[4] = {0,1,3,4};
       	for (int i=0; i<4; i++)
		if (mxGetM(prhs[dbyone[i]])!=dim || mxGetN(prhs[dbyone[i]])!=1)
			mexErrMsgIdAndTxt("Horace:cell_idx:dimensions","Inconsistent dimensionality");
	
	intType *cell, *span, idx_offset;
	double *X, *minX, *delX, bin_shift;
	cell = (intType *)mxGetData(prhs[0]);
	span = (intType *)mxGetData(prhs[1]);
	   X = (double  *)mxGetData(prhs[2]);
	minX = (double  *)mxGetData(prhs[3]);
	delX = (double  *)mxGetData(prhs[4]);
	bin_shift = double( mxGetScalar(prhs[5]) );
	idx_offset = intType( mxGetScalar(prhs[6]) );

	// It's not safe to access MATLAB memory from within threads, so allocate a C array to hold the linear indexing
	intType *idx = safealloc<intType>(num);
	// Now do the real work! 
//	printf("Starting real work in cppCellIdx ... ");
	cell_idx(nthreads,dim,cell,span,num,X,minX,delX,bin_shift,idx);
//	printf("done.\n");
	// Hard work finished. Now allocate final correct-size output array in MATLAB
	plhs[0] = mxCreateUninitNumericMatrix(num,1,iic,mxREAL); // iic == Input Integer Class
	intType *matlabidx = (intType *)mxGetData(plhs[0]);
	for (intType i=0; i<num; i++)
		matlabidx[i] = idx[i]+idx_offset;

	delete[] idx;
	//printdbg"mexFunction finished");
}
