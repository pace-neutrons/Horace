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
template <typename T, typename R> void collect_chunk(const T start, const T stop, const T *ipx, const T *npt, const T *fst, const T *lst, const T *ipt, const R *vxr, const R *sqe, R *sig, R *var){
	/* For the pixel information:
	 * 	ipx	the index into sig/var for each pixel
	 * 	npt	the number of points contributing to each pixel
	 * 	fst	the first index into the overlapping point-pixel vectors
	 * 	lst	the last index into the overlapping point-pixel vectors
	 * overlapping point-pixel information:
	 * 	ipt 	the indicies into the S(Q,E) array for each overlapping point
	 * 	vxr	the value of the resolution function R(Q,E) at the overlapping-point position
	 * and the unique point position signals 	
	 *	sqe 	the value of S(Q,E) at unique point positions
	 *
	 * Calculate the signal and variance per pixel by accumulating the contributing points
	 */
	R sum_s, sum_s2, sj;
	for (T i=start; i<stop; i++){
		if (npt[i]>0){ // nothing to do for zero contributing points
			sum_s  = R(0);
			sum_s2 = R(0);
			for (T j=fst[i]; j<lst[i]; j++){
				sj = vxr[j-1]*sqe[ipt[j-1]-1]; // j-1 since fst,lst are MATLAB-indexing; ipt[j-1]-1 for the same reason
				sum_s  += sj;
				sum_s2 += sj*sj;
			}
			sig[ipx[i]-1] = sum_s/R(npt[i]);
			var[ipx[i]-1] = abs( sum_s2 - sum_s*sum_s )/R(npt[i]*npt[i]);
		}
	}
}
template <typename T, typename R> void collect(const int nth, const T npx, const T *ipx, const T *npt, const T *fst, const T *lst, const T *ipt, const R *vxr, const R *sqe, R *sig, R *var){
	T chunk = npx/nth;
	if (chunk<1||nth==1)
		collect_chunk(T(0),npx,ipx,npt,fst,lst,ipt,vxr,sqe,sig,var);
	else{
		T *offset = safealloc<T>(nth+1);
		for (T i=1; i<nth; i++) offset[i]=i*chunk; offset[nth]=npx;
#pragma omp parallel shared(offset,ipx,npt,fst,lst,ipt,vxr,sqe,sig,var)
		{
			T tt = omp_get_thread_num();
			collect_chunk(offset[tt],offset[tt+1],ipx,npt,fst,lst,ipt,vxr,sqe,sig,var);
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
	if (nrhs != 7) mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:nrhs", "Seven input aruments expected.");
	if (nlhs != 2) mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:nlhs", "One output argument required.");
	// check input types and sizes
	mxClassID iic = mxGetClassID(prhs[0]);
	// sizes of the pixel information arrays
	intType m,n;
	m = intType( mxGetM(prhs[0]) );
	n = intType( mxGetN(prhs[0]) );

	int iinpt[5] = {0,1,2,3,4};
	for (int i=0; i<5; i++){
		if (mxGetClassID(prhs[iinpt[i]]) != iic)
			mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:intType","all integer inputs should be of the same type");
	}
	int dblinpt[2] = {5,6};
	for (int i=0; i<2; i++){
		if (!mxIsDouble(prhs[dblinpt[i]])||mxIsComplex(prhs[dblinpt[i]]))
			mexErrMsgIdAndTxt("Horace:collect_points_into_pixels:notDouble","Expected real double input.");
	}
	for (int i=0; i<7; i++){
		if (mxGetM(prhs[i])!=m)
			mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:dimensions","all inputs must have identical first dimension.");
	}
	for (int i=0; i<4; i++){
		if (mxGetN(prhs[i])!=n)
			mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:dimensions","all pixel information inputs must have compatible dimensions.");
	}
	intType nOverlap = intType(mxGetN(prhs[4]));
	if (mxGetN(prhs[5])!=nOverlap)
		mexErrMsgIdAndTxt("HORACE:collect_points_into_pixels:dimensions","iPt and VxR must represent equivalent pixel-point overlap.");

	intType nUniquePts = intType(mxGetN(prhs[6]));

	// Get handles to MATLAB data
	intType *iPx, *nPt, *fst, *lst, *iPt;
	double *VxR, *SQE;
	iPx = (intType *)mxGetData(prhs[0]);
	nPt = (intType *)mxGetData(prhs[1]);
	fst = (intType *)mxGetData(prhs[2]);
	lst = (intType *)mxGetData(prhs[3]);
	iPt = (intType *)mxGetData(prhs[4]);
	VxR = (double  *)mxGetData(prhs[5]); 
	SQE = (double  *)mxGetData(prhs[6]);

	// It's not safe to write to MATLAB memory from within threads, so allocate a C array to hold the signal and variance
	intType num=n*m;
	double *sig = safealloc<double>(num), *var = safealloc<double>(num);
	// Now do the real work! 
//	printf("Starting real work in cppCellIdx ... ");
	collect(nthreads,num,iPx,nPt,fst,lst,iPt,VxR,SQE,sig,var);
//	printf("done.\n");
	// Hard work finished. Now allocate final correct-size output arrays in MATLAB
	plhs[0] = mxCreateUninitNumericMatrix(m,n,mxDOUBLE_CLASS,mxREAL);
	plhs[1] = mxCreateUninitNumericMatrix(m,n,mxDOUBLE_CLASS,mxREAL); 
	double *matS = (double *)mxGetData(plhs[0]);
	double *matV = (double *)mxGetData(plhs[1]);
	for (intType i=0; i<num; i++){
		matS[i]=sig[i];
		matV[i]=var[i];
	}
	delete[] sig; delete[] var;
	//printdbg"mexFunction finished");
}
