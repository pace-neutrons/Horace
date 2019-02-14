#include<string>
#include<iostream>
#include "mex.h"
#include "matrix.h"
#include <omp.h>

char * spacepad(int c){
	char *pad = new char[c+1]();
	for (int i=0; i<c; i++) pad[i]=' ';
	return pad;
}
template <typename T> void print_matrix(const T n, const double *A){
	printf("[ ");
	for (int i=0; i<n*n; i++) printf("%g ",A[i]);
	printf("]");
}
template <typename R, typename T> R * safealloc(const T d){
	R *out = nullptr;
	out = new R[d](); // R[d] does not initialize to zero. R[d]() does!
	if (out == 0) mexErrMsgIdAndTxt("HORACE:safealloc:allocation", "out of memory");
	return out;
}

template <typename T, typename R> void integrate_project_one(const T d, const R *M, const T i, R *P){
	T *k; 
	k = safealloc<T>(d-1);
	T j=0;
	for (T l=0; l<d; l++) if (l!=i) k[j++]=l; 
	R *b, two=2.0;
	b = safealloc<R>(d-1);
	for (T l=0; l<d-1; l++) b[l] = (M[ k[l] + i*d ] + M[ i + k[l]*d ])/two;
	R Miid = M[i+i*d];
	for (T l=0; l<d-1; l++)	for (T j=0; j<d-1; j++) P[l + j*(d-1)] = M[ k[l] + k[j]*d] - b[l]*b[j]/Miid;

	delete[] k; delete[] b;
}

template <typename T, typename R> void integrate_project_chunk(const T d, const T start, const T stop, const R *M, const T i, R *P){
	T sM=d*d;
	T sP=sM-2*d+1;
	for (T j=start; j<stop; j++) integrate_project_one(d,M+sM*j,i,P+sP*j);
}
template <typename T, typename R> void integrate_project_chunks(const int nthreads, const T d, const T m, const R *M, const T i, R *P){
	T chunk = m/nthreads;
	if (chunk<1||nthreads==1)
		integrate_project_chunk(d,T(0),m,M,i,P);
	else {
		T *offset = safealloc<T>(nthreads+1); // initialized to 0
		for (T j=1; j<nthreads; j++) offset[j]=j*chunk; offset[nthreads]=m;
#pragma omp parallel firstprivate(d,i) shared(offset,M,P)
		{
		T thisthread = omp_get_thread_num();
		integrate_project_chunk(d,offset[thisthread],offset[thisthread+1],M,i,P);
		}
	}
}

int test_integrate_project_one(int depth){
	int d = 3;
	double M[9] = {1,0,0, 0,1,0, 0,0,1}, Mp[4]={0,0, 0,0};
	std::cout << spacepad(depth) << "M = eye(3) => Mp = eye(2) for each index" << std::endl;
	for (int i=0; i<d; i++){
		printf("%s",spacepad(3+depth));
		printf("M="); print_matrix(d,M); printf(",i=%d => ",i);
		integrate_project_one(d,M,i,Mp);
		printf("Mp="); print_matrix(d-1,Mp); printf("\n");
		if (Mp[0]!=1.0) return -2;
		if (Mp[1]!=0.0) return -2;
		if (Mp[2]!=0.0) return -2;
		if (Mp[3]!=1.0) return -2;
	}
	std::cout << spacepad(depth) << "M = ones(3,3) => Mp = zeros(2,2) for each index" << std::endl;
	for (int i=0; i<d*d; i++) M[i]=1.0; 
	for (int i=0; i<d; i++){
		printf("%s",spacepad(3+depth));
		printf("M="); print_matrix(d,M); printf(",i=%d => ",i);
		integrate_project_one(d,M,i,Mp);
		printf("Mp="); print_matrix(d-1,Mp); printf("\n");
		if (Mp[0]!=0.0) return -2;
		if (Mp[1]!=0.0) return -2;
		if (Mp[2]!=0.0) return -2;
		if (Mp[3]!=0.0) return -2;
	}

	return 0;
}

int test_omp(int d){
	int i=10;
	int *subtotal = safealloc<int>(omp_get_max_threads());

	#pragma omp parallel firstprivate(i) shared(subtotal)
	{
		int t = omp_get_thread_num();
		i = 1000 + omp_get_thread_num();
		subtotal[t]=i;
	}
	int total=0;
	printf("[ ");
	for (int i=0;i<omp_get_max_threads();i++) {
		total+=subtotal[i];
		printf("%d ",subtotal[i]);
	}
	printf("] total = %d\n", total);
	return 0;
}


typedef int (*test_function)(int);
void reportTest(test_function f, const char *test){
	std::cout << spacepad(1) << test << std::endl;
	std::cout << spacepad(4) << "test " << (f(7) ? "failed" : "passed")<< std::endl;
}
int test_everything(){
reportTest( &test_integrate_project_one,      "integrate_project_one");
reportTest( &test_omp,      "omp");
    return 0;
}

using intType = mwSize;
// The gateway function which MATLAB can call directly
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	int nthreads = omp_get_max_threads();
	omp_set_num_threads(nthreads);
	// printf("Maximum OpenMP threads %d. We're using %d threads\n",nthreads,omp_get_num_threads());
	if (nrhs == 0){
	test_everything();
	return;
	}
	
	
	// check number of inputs and outputs
	if (nrhs != 4) mexErrMsgIdAndTxt("HORACE:integrate_project:cPointsInResolutionnrhs", "Four input aruments expected.");
	if (nlhs != 1) mexErrMsgIdAndTxt("HORACE:integrate_project:cPointsInResolutionnlhs", "One output arguments required.");
	// check input types
	mxClassID iic = mxGetClassID(prhs[0]);
	if (!mxIsScalar(prhs[0])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The dimensionality must be scalar");
	if (!mxIsScalar(prhs[1])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The number of matricies must be scalar");
	if (!mxIsScalar(prhs[3])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The index must be scalar");
	int intInputs[2] = { 1, 3 };
	for (int i=0; i < 2; i++) {
		if (mxGetClassID(prhs[intInputs[i]]) != iic) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:intType", "all integer inputs should be of the same type");
	}

	if (!mxIsDouble(prhs[2])||mxIsComplex(prhs[2])){
		mexErrMsgIdAndTxt("HORACE:integrate_project:notDouble","Matrix input is expected to have real double elements");
	}

	// pull together sizes
	intType dim, num, idx;
	dim = intType( mxGetScalar(prhs[0]) ); // the dimensionality of M
	num = intType( mxGetScalar(prhs[1]) ); // the number of matricies in M
	idx = intType( mxGetScalar(prhs[3]) ); // the index to project out

	if (idx<1 || idx>dim) mexErrMsgIdAndTxt("HORACE:integrate_project:bad_index","The index should be a valid (MATLAB) subindex into the square matricies of M");
	
	if (mxGetNumberOfElements(prhs[2]) != dim*dim*num) mexErrMsgIdAndTxt("HORACE:integrate_project:dimensions","The size of M is not as expected!");

	double *M;
	M = (double *)mxGetData(prhs[2]);

	// We *could* allocate the output in MATLAB already, but we'll wait.
	// Just allocate what we actually need to perform the calculations in C.
	double *Mp = safealloc<double>( (dim-1)*(dim-1)*num );
	// Now do the real work! // We're subtracting 1 from idx to convert from MATLAB to C indexing
	// 
	integrate_project_chunks(nthreads,dim,num,M,idx-1,Mp);


	// Hard work finished. Now allocate final correct-size output array in MATLAB
	// The first four outputs have the same type and size. Allocate ...
	intType ndim=3, dims[3] = {dim-1,dim-1,num}, numel=1;
	for (intType i = 0; i<ndim; i++) numel *= dims[i];
	plhs[0] = mxCreateUninitNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
//	printf("Will now copy-back %d total elements to MATLAB\n",numel);
	double *matlabMp = (double *)mxGetData(plhs[0]);
	for (intType i = 0; i < numel; i++){
		matlabMp[i] = Mp[i];
	}

	delete[] Mp;
	//printdbg"mexFunction finished");
}
