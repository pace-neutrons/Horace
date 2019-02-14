#include<string>
#include<iostream>
#include<cmath>
#include "mex.h"
#include "matrix.h"
//#include "lapack.h"
//#include<limits>
#include <omp.h>


template <typename R, typename T> R * safealloc(const T d){
	R *out = nullptr;
	out = new R[d](); // R[d] does not initialize to zero. R[d]() does!
	if (out == 0) mexErrMsgIdAndTxt("HORACE:safealloc:allocation", "out of memory");
	return out;
}

template <typename T, typename R> R det_and_inv(const T d, const R *A, R *M){
	// Calculate the characteristic polynomial of the square matrix A
	// using the Faddeev-LeVerrier algorithm, and use these to determine
	// the determinant and inverse of A.
	
	R *coef = safealloc<R>(d+1);
	coef[d]=R(1);
	for (T i=0;i<d;i++) for (T j=0;j<d;j++) M[i+j*d]=R(0); // make sure we start with zero!
	R *AMk = safealloc<R>(d*d);
	// to start M=M0 (it's been initialized to zero)
	// and AMk is correct for calculating M_1
	for (T k=0; k<d; k++){
/*
	printf("coef = %s\n", sprint_vector(d+1,coef) );
      	printf("M_{%d}:\n%s\n",k,sprint_matrix(d,M));
      	printf("A*M_{%d}:\n%s\n",k,sprint_matrix(d,AMk));
*/
		// Calculate M_{k+1} = A*M_{k} + c_{n-k}*I
		for (T i=0;i<d;i++) for (T j=0;j<d;j++) M[i+j*d]=AMk[i+j*d]; //here AMk is still A*M_{k-1}
		for (T i=0;i<d;i++) M[i+i*d]+=coef[d-k];
		// Calculate A*M_k 
		for (T i=0;i<d;i++) for (T j=0;j<d;j++) {
			R tmp =0;
			for (T l=0;l<d;l++)
				tmp += A[i+l*d]*M[d*j+l];
			AMk[i+j*d]=tmp;
		}
		// Calculate c_{n-k} -- making sure we use zero-based indexing for k!
		for (T i=0;i<d;i++) coef[d-k-1]+=AMk[i+i*d]; // the trace of A*Mk
		coef[d-k-1]/=-R(k+1);  // divide by k+1 since we're using C indexing
	}
	// Now M == M_n. And we can calculate the inverse of A by A^-1 = -M_n/c_0
	// where c_0 = coef[0]. Plus the determinant of A is det(A)=c_0/(-1)^n
	for (T i=0;i<d;i++) for (T j=0;j<d;j++) M[i+j*d]/= -1*coef[0];
	
	R determinant = coef[0];
	delete[] coef; delete[] AMk;
		
	if ( 2*T(d/2) == d ) // d is even, -1^d = 1
		return determinant;
	else // d is odd, -1^d = -1
		return R(-1)*determinant;
		
}

template <typename T, typename R> R resmat_from_cov_one(const R pid, const T d, const R *C, R *M){
	R det = det_and_inv(d,C,M); // sets M to inv(C);
	return pid*sqrt(det); // the volume of the Gaussian resolution is (2*pi)^(d/2) *sqrt(det(C))
}	
template <typename T, typename R> void resmat_from_cov_chunk(const R pid, const T d, const T start, const T stop, const R *C, R *M, R *vol){
	T smat = d*d;
	for (T j=start; j<stop; j++)
		vol[j] = resmat_from_cov_one(pid,d,C+smat*j,M+smat*j);
}
template <typename T, typename R> void resmat_from_cov(const int nthreads, const R pid, const T d, const T m, const R *C, R *M, R *vol){
	T chunk = m/nthreads;
	if (chunk<1||nthreads==1)
		resmat_from_cov_chunk(pid,d,T(0),m,C,M,vol);
	else {
		T *offset = safealloc<T>(nthreads+1); // initialized to 0
		for (T j=1; j<nthreads; j++) offset[j]=j*chunk; offset[nthreads]=m;
#pragma omp parallel firstprivate(pid,d) shared(offset,C,M,vol)
		{
		T thisthread = omp_get_thread_num();
		resmat_from_cov_chunk(pid,d,offset[thisthread],offset[thisthread+1],C,M,vol);
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
	if (nrhs != 4) mexErrMsgIdAndTxt("HORACE:covariance2resolutionmatrix:nrhs", "Four input aruments expected.");
	if (nlhs < 1) mexErrMsgIdAndTxt("HORACE:covariance2resolutionmatrix:nlhs", "One output arguments required.");
	// check input types
	mxClassID iic = mxGetClassID(prhs[0]);
	if (!mxIsScalar(prhs[0])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The dimensionality must be scalar");
	if (!mxIsScalar(prhs[1])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The number of matricies must be scalar");
	if (!mxIsScalar(prhs[3])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The volume prefactor must be scalar");
	if (mxGetClassID(prhs[1]) != iic) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:intType", "all integer inputs should be of the same type");

	if (!mxIsDouble(prhs[2])||mxIsComplex(prhs[2])){
		mexErrMsgIdAndTxt("HORACE:covariance2resolutionmatrix:notDouble","Matrix input is expected to have real double elements");
	}
	if (!mxIsDouble(prhs[3])||mxIsComplex(prhs[3])){
		mexErrMsgIdAndTxt("HORACE:covariance2resolutionmatrix:notDouble","Volume prefactor input is expected to have real double elements");
	}

	// pull together sizes
	intType dim, num;
	dim = intType( mxGetScalar(prhs[0]) ); // the dimensionality of M
	num = intType( mxGetScalar(prhs[1]) ); // the number of matricies in M

	if (mxGetNumberOfElements(prhs[2]) != dim*dim*num) mexErrMsgIdAndTxt("HORACE:covariance2resolutionmatrix:dimensions","The size of C is not as expected!");

	double *C, pid;
	C = (double *)mxGetData(prhs[2]);
	pid = double( mxGetScalar(prhs[3]));

	// We *could* allocate the output in MATLAB already, but we'll wait.
	// Just allocate what we actually need to perform the calculations in C.
	double *M = safealloc<double>( dim*dim*num );
	double *vol = safealloc<double>(num);
	// Now do the real work! 
//	printf("Starting real work in cppResolutionMatrixFromCovariance ... ");
	resmat_from_cov(nthreads,pid,dim,num,C,M,vol);
//	printf("done.\n");
	// Hard work finished. Now allocate final correct-size output array in MATLAB
	intType ndim=3, dims[3] = {dim,dim,num}, numel=1;
	for (intType i = 0; i<ndim; i++) numel *= dims[i];
	plhs[0] = mxCreateUninitNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
	//printf("Will now copy-back %d total elements to MATLAB\n",numel);
	double *matlabM = (double *)mxGetData(plhs[0]);
	for (intType i = 0; i < numel; i++){
		matlabM[i] = M[i];
	}
	if (nlhs>1) { // copy over the volume too
		plhs[1] = mxCreateUninitNumericMatrix(1,num,mxDOUBLE_CLASS,mxREAL);
		double *matlabVol = (double *)mxGetData(plhs[1]);
		for (intType i=0; i<num; i++){
			matlabVol[i] = vol[i];
		}
	}

	delete[] M; delete[] vol;
	//printdbg"mexFunction finished");
}
