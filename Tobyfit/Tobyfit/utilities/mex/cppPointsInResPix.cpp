/*	cPointsInResolution(total,cells,span,Y,Yhead,Ylist,X,M,V,Xhead,Xlist,frac)
Determine the Y points within resolution for each of the X pixels.

Input:
0	total	the total number of cells: scalar; prod(cells)
1	cells	the number of neighbourhood cells along each dimension: (1,dim)
2	span	the span for each dimension -- could be easily calculated from cells: (1,dim)

3	Y		the point(s) to check: (dim,n)
4	Yhead	the head of a linked list putting points into cells: (1,prod(nCell))
5	Ylist	the list of a linked list putting points into cells: (1,n)

6	X		the pixel(s) to check: (dim,m)
7	M		the pixel resolution gaussian widths: (dim,dim,m)
8	V		the pixel resolution volumes: (1,m)
9 c 	the cell index for each pixel: (1,m)

10	frac	the fractional probability for deciding if a point is within resolution

Output:
0	iPx		indicies into X: (1,m); some permutation of 1:m
1	nPt		the number of points within resolution for each pixel: (1,m)
2	fst		the first index into iPt of a point within resolution for each pixel: (1,m)
3	lst		the last index into iPt of a point within resolution for each pixel: (1,m)
4	iPt		indicies into Y for all points within resolution of *a* pixel: between (1,0) and (1,m*n)
5	VxR		the value of V(i)*R(i)[Y-X(i)] for eaxh point in iPt: same sized as iPt
*/
#include<string>
#include<iostream>
#include "mex.h"
#include "matrix.h"
#include "math.h"

// #ifndef _OPENMP
// void omp_set_num_threads(int nThreads) {};
// #define omp_get_num_threads() 1
// #define omp_get_max_threads() 1
// #define omp_get_thread_num()  0
// #else
// #include <omp.h>
// #endif
#include <omp.h>

// Simple utility used for printing a number of spaces. Used in debugging and testing.
char * spacepad(int c){
	char *pad = new char[c+1]();
	for (int i=0; i<c; i++) pad[i]=' ';
	return pad;
}

template <typename R, typename T> R * safealloc(const T d){
	R *out = nullptr;
	out = new R[d](); // R[d] does not initialize to zero. R[d]() does!
	if (out == 0) mexErrMsgIdAndTxt("HORACE:safealloc:allocation", "out of memory");
	return out;
}
template <typename T> void matlab_lin2sub(const T d, const T *span, const T linindex, T *subindex) {
	T i, remaining = linindex;
	// In the next line it's important to remember that j is *not* an index into
	// span or subindex as it takes values between *1* and *d*!
	// since T is likely unsigned we can't just go from d-1 to j<0 as j will *always* be positive
	// instead we need to introduce a second counter to make sure we index correctly
	for (T j = d; j > 0; j--) {
		i = j-1; // always valid since j>=1
		subindex[i] = T(remaining/span[i]);
		remaining -= span[i] * subindex[i];
	}
}
template <typename T>    T matlab_sub2lin(const T d, const T *span, const T *subindex) {
	T lin = 0;
	for (T i = 0; i < d; i++) lin += subindex[i] * span[i];
	return lin;
}
template <typename T>    T neighbouring_cells(const T d, const T *N, const T *span, const T linindex, const T maxneighbours,T *neighbours) {
	T *subindex = safealloc<T>(d);
	// get the subscripted index to the central (linear indexed) cell
	matlab_lin2sub(d, span, linindex, subindex);

	T *localspan = safealloc<T>(d);
	localspan[0] = T(1); // the first spanning index is always 1
	for (int i = 1; i < d; i++) localspan[i] = localspan[i-1]*T(3); // all dimensions of the local hypercube are 3
	T *localsubidx = safealloc<T>(d);
	int64_t mzp[3] = { -1, 0, 1 };

	T neighbourCount = 0;
	bool neighbour_ok = true;
	for (T i = 0; i < maxneighbours; i++) {
		neighbour_ok = true;
		// get the subscripted index "vector" pointing to the ith neighbour
		matlab_lin2sub(d, localspan, i, localsubidx);
		// add this to the central cell's subscripted indicies
		for (T j = 0; j < d; j++) {
			if ( (subindex[j] ==0 && mzp[localsubidx[j]]==-1) || (subindex[j]+1==N[j] && mzp[localsubidx[j]]==1) )
				neighbour_ok = false;
			else {
				switch (mzp[localsubidx[j]]) {
					case -1:
					localsubidx[j] = subindex[j]-1;
					break;
					case 1:
					localsubidx[j] = subindex[j]+1;
					break;
					default:
					localsubidx[j] = subindex[j];
					break;
				}
				// The following typecasts mzp[localsubidx[j]] to type T. Which, if T is a UInt, will cause a problem!
				// localsubidx[j] = subindex[j] + mzp[localsubidx[j]];
			}

			if (!neighbour_ok) break; // break to stop checking once a single subscripted index is bad
		}
		if (neighbour_ok) {
			// localsubidx is now the overall subscripted indicies to the neighbour, we want the linear index back
			neighbours[neighbourCount++] = matlab_sub2lin(d, span, localsubidx);
		}
	}
	delete[] subindex; delete[] localspan; delete[] localsubidx;
	return neighbourCount;
}
template <typename T, typename R> T points_in_resolution_pixel(
	const T d, const T nNeighbourCells, const T *neighbourCells,
	const R *Y, const T *Yhead, const T* Ylist,
	const R *X, const R *M, const R fracV,
	T *YiX, R *VxR) {
	/*	For the [d]-dimensional position [X], resolution Gaussian widths matrix [M]
		and fractional-volume cutoff [fracV] describing a single detector pixel,
		determine which of the points [Y], arranged in the linked list [Yhead]/[Ylist]
		and a number of neughbouring cells [nNeighbourCells] with cell indicies
		[neighbourCells], are within resolution.

		Inputs:
			d					the dimensionality of the points/pixels
			nNeighbourCells		the number of cells neighbouring the cell in which our
								pixel is located
			neighbourCells		a vector of the neighbouring cell indicies (into Yhead)
			Y					a (d,?) array of *ALL* points
			Yhead				a (>=nNeighbourCells,) vector of the first MATLAB index
								into Y for the points in a given cell index
			Ylist				the linked list relating all points within all cells
			X					a (d,) vector of the position of *one* pixel
			M					a (d,d) matrix of the Gaussian widths of the resolution
								function for a single pixel
			fracV				the resolution volume times the fractional-cutoff, for
								deciding whether a point is within resolution
		Outputs:
			YiX					the MATLAB-style indicies of all Y within resolution
			VxR					the value of the resolution function for these points
		Returned:
			the total number of points that are within resolution for this pixel
	*/
	T points_in_resolution = 0;
	R *v = safealloc<R>(d);
	R vMv, expvMv;

	T point_offset;
	// Loop over the neighbouring cells
	for (T i = 0; i < nNeighbourCells; i++) {
		// Loop over the points within each neighbouring cell.
		for (T j = Yhead[neighbourCells[i]]; j > 0; j = Ylist[j-1]) {
			point_offset = d*(j - 1); // j-1 for C-style point index
			// calculate the vector from the pixel to the point; Y[j]-X
			for (T k = 0; k < d; k++) v[k] = Y[point_offset + k] - X[k];
			// calculate v'*M*v == sum( dot(v, M*v) )
			vMv = 0;
			for (T ii = 0; ii < d; ii++)
				for (T jj = 0; jj < d; jj++)
					vMv += v[ii] * M[ii + d * jj] * v[jj]; // ii + d*jj to match MATLAB matrix memory layout
			expvMv = exp(-vMv / 2.0);
			if (expvMv >= fracV) {
				VxR[points_in_resolution] = expvMv; // record the value of the resolution function
				YiX[points_in_resolution] = j; // and this (MATLAB style) point index -- plus increment points_in_resolution after
				points_in_resolution++;
			}
		}
	}
	delete[] v;
	return points_in_resolution;
}
template <typename T, typename R> T points_in_resolution(
	const T d, const T *cells, const T *spans,
	const T n, const R *Y, const T *Yhead, const T *Ylist,
	const T m, const R *X, const R *M, const  R *V, const  T *c, const R frac,
	T *nYiX, T **allYiX, R **allVxR) {
	// The maximum number of neighbouring cells is 3^dimensions
	T maxNeighbours = 1;
	for (int i = 0; i < d; i++) maxNeighbours *= T(3); // maxNeighbours = 3^d

	T nthreads = omp_get_max_threads();
	T *subtotal = safealloc<T>(nthreads); // safealloc initializes to zero
	T dd=d*d, total = 0;
	#pragma omp parallel firstprivate(d,dd,n,frac,maxNeighbours) \
	shared(cells,spans,Y,Yhead,Ylist,X,M,V,c,nYiX,allYiX,allVxR,subtotal)
	{
	//create neighbourCells and temporary YinX and VxR arrays
	T pir, nNeighbours, *neighbourCells = safealloc<T>(maxNeighbours);
	T *tYiX = safealloc<T>(n);
	R *tVxR = safealloc<R>(n);
	// loop directly over all pixels, since we know the cell index of each pixel:
	#pragma omp for
	for (int i=0; i<m; i++){
		// printf("Thread %d is in charge of pixel %d\n",omp_get_thread_num(),i);
		nNeighbours = neighbouring_cells(d, cells, spans, c[i], maxNeighbours, neighbourCells);
		pir=points_in_resolution_pixel(d,nNeighbours,neighbourCells,Y,Yhead,Ylist,X+d*i,M+dd*i,frac*V[i],tYiX,tVxR);
		// if (pir>n) mexErrMsgIdAndTxt("HORACE:points_in_resolution:outofbounds","Number of points in resolution for one pixel exceeds number of points!");
		if (pir>0 && pir<=n){
			// Allocate inner array for storing output
			allYiX[i] = safealloc<T>(pir);
			allVxR[i] = safealloc<R>(pir);
			for (T j=0; j< pir; j++){
				allYiX[i][j] = tYiX[j];
				allVxR[i][j] = tVxR[j];
			}
			nYiX[i] = pir;
			subtotal[omp_get_thread_num()] += pir;
			// total += pir;
		} else {
			nYiX[i] = 0;
		}
	}
	// temporary arrays no longer needed:
	delete[] tYiX; delete[] tVxR; delete[] neighbourCells;
	}
	for (int i=0; i<nthreads; i++) total +=subtotal[i];
	return total;
}

void print_points(const int depth, const int d, const int npt, const int* ptIdx, const double* ptVR, const double* pts){
	for (int i=0; i<npt; i++){
		std::cout << spacepad(depth) << i+1 << " " << ptIdx[i] << " " << ptVR[i] << " [ ";
		for (int j=0; j<d; j++){
			std::cout << pts[d*(ptIdx[i]-1)+j] << " ";
		}
	std::cout << "]" << std::endl;
	}
}
int test_safealloc(int depth){
    int *i = safealloc<int>(10);
    delete[] i;
    double *f = safealloc<double>(10);
    delete[] f;
    return 0;
}
int test_matlab_lin2sub(int depth){
    int d = 2;
    int s[2], span[2] = {1,3};
    matlab_lin2sub(d,span,0,s); if (s[0]!=0||s[1]!=0) return -1;
    matlab_lin2sub(d,span,1,s); if (s[0]!=1||s[1]!=0) return -1;
    matlab_lin2sub(d,span,2,s); if (s[0]!=2||s[1]!=0) return -1;
    matlab_lin2sub(d,span,3,s); if (s[0]!=0||s[1]!=1) return -1;
    matlab_lin2sub(d,span,4,s); if (s[0]!=1||s[1]!=1) return -1;
    matlab_lin2sub(d,span,5,s); if (s[0]!=2||s[1]!=1) return -1;
    matlab_lin2sub(d,span,6,s); if (s[0]!=0||s[1]!=2) return -1;
    return 0;
}
int test_matlab_sub2lin(int depth){
    int d = 2;
    int s[2]={0,0}, span[2]={1,3};
    if ( 0 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=1;
    if ( 1 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=2;
    if ( 2 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=0; s[1]=1;
    if ( 3 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=1;
    if ( 4 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=2;
    if ( 5 != matlab_sub2lin(d,span,s) ) return -1;
    s[0]=0; s[1]=2;
    if ( 6 != matlab_sub2lin(d,span,s) ) return -1;
    return 0;
}
int test_neighbouring_cells(int depth){
    int d=2, N[2]={3,3}, span[2]={1,3}, centre=4;
    int nn, mn=9, nlist[9];
    nn = neighbouring_cells(d,N,span,centre,mn,nlist);
    if (nn!=mn) return -1;
    for (int i=0; i<nn; i++) if (nlist[i]!=i) return -2;

    nn = neighbouring_cells(d,N,span,0,mn,nlist);
    if (4!=nn) return -1;
    if (0!=nlist[0]||1!=nlist[1]||3!=nlist[2]||4!=nlist[3]) return -2;
//    for (int i=0; i<nn; i++){
//        std::cout << "neighbour " << i << " is " << nlist[i] << std::endl;
//    }

    return 0;
}
int test_points_in_resolution_pixel(int depth){
    int d=2, nnc=1, nc[1]={0}, nYiX;
    double Y[6]={1.,0.,0.,6.,0.,1.}; int Yhead[1]={3}, Ylist[3]={0,1,2};
    double X[2]={0.,0.}, M[4]={1.,0.,0.,1./4.}, V=1/(2*3.14159*2), frac = 0.5, fracV;
		fracV = frac*V;
    int YiX[3];
    double VxR[3];

		nYiX = points_in_resolution_pixel(d,nnc,nc,Y,Yhead,Ylist,X,M,fracV,YiX,VxR);
		if (nYiX!=2) return -1;

		d=3;
		double Y1[9]={0.,1.,0.,1.,0.,0.,0.,2.,1.}, X1[3]={0.,0.,0.}, M1[9] = {1.,0.,0.,0.,1.,0.,0.,0.,1./2.};
		V = 0.28209479; // 1/sqrt(2*pi*2)
		fracV = frac*V;
		nYiX = points_in_resolution_pixel(d,nnc,nc,Y1,Yhead,Ylist,X1,M1,fracV,YiX,VxR);
		if (2!=nYiX) return -1;
		if (2!=YiX[0]) return -2;
		if (1!=YiX[1]) return -2;

		// std::cout << spacepad(depth) << "The number in resolution is " << nYiX << std::endl;
		// print_points(depth+4,d,nYiX,YiX,VxR,Y1);
    return 0;
}

int test_points_in_resolution(int depth){
	int d=2, cells[2]={3,3}, spans[2]={1,3};
	int n=5, Yhead[9]={0,5,0,0,4,0,0,0,0}, Ylist[5]={0,0,1,3,2};
	double Y[10]={1.,0., -1.,3., 0.,1., 1.,1., 1.,4.}; // five points, three in the centre cell, two in the cell to the left
	double X[4]={0.,-1., 0.,4.}, M[8]={1.,0.,0.,1./4., 1.,0.,0.,1.}, V[2]={1/(2*3.14159*2),1/(2*3.14159)}, frac = 0.5;
	int m=2, Xcell[2]={4,4}; // two pixels in the centre cell
	int nYiX[2], *allYiX[2];
	double *allVxR[2];

	int total = points_in_resolution(d,cells,spans,n,Y,Yhead,Ylist,m,X,M,V,Xcell,frac,nYiX,allYiX,allVxR);
  std::cout << spacepad(depth) << "found " << total << " points in resolution. Expected 6" << std::endl;
	if (6!=total) return -1;
	for (int i=0; i<2; i++){
		std::cout << spacepad(depth) << "found " << nYiX[i] << " in-resolution points for pixel " << i+1 << std::endl;
		print_points(depth+4,d,nYiX[i],allYiX[i],allVxR[i],Y);
	}
	if (4!=nYiX[0]) return -2;
	if (2!=allYiX[0][0]) return -3;
	if (4!=allYiX[0][1]) return -3;
	if (3!=allYiX[0][2]) return -3;
	if (1!=allYiX[0][3]) return -3;
	if (2!=nYiX[1]) return -2;
	if (5!=allYiX[1][0]) return -3;
	if (2!=allYiX[1][1]) return -3;

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
    std::cout << spacepad(4) << "test " << (f(4) ? "failed" : "passed")<< std::endl;
}
int test_everything(){
	  reportTest( &test_omp,                       "OpenMP");
		reportTest( &test_safealloc,                 "safealloc");
		reportTest( &test_matlab_lin2sub,            "matlab_lin2sub");
		reportTest( &test_matlab_sub2lin,            "matlab_sub2lin");
		reportTest( &test_neighbouring_cells,        "neighbouring_cells");
		reportTest( &test_points_in_resolution_pixel,"points_in_resolution_pixel");
		reportTest( &test_points_in_resolution,      "points_in_resolution");
    return 0;
}

/*
0	total	the total number of cells: scalar; prod(cells)
1	cells	the number of neighbourhood cells along each dimension: (1,dim)
2	span	the span for each dimension -- could be easily calculated from cells: (1,dim)

3	Y		the point(s) to check: (dim,n)
4	Yhead	the head of a linked list putting points into cells: (1,prod(nCell))
5	Ylist	the list of a linked list putting points into cells: (1,n)

6	X		the pixel(s) to check: (dim,m)
7	M		the pixel resolution gaussian widths: (dim,dim,m)
8	V		the pixel resolution volumes: (1,m)
9 c 	the cell index for each pixel: (1,m)

10	frac	the fractional probability for deciding if a point is within resolution

*/

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
	if (nrhs != 11) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:nrhs", "Twelve input aruments expected.");
	if (nlhs != 6)  mexErrMsgIdAndTxt("HORACE:cPointsInResolution:nlhs", "Six output arguments required.");
	// check input types
	mxClassID iic = mxGetClassID(prhs[0]);
	if (!mxIsScalar(prhs[0])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The total input must be scalar");
	int intInputs[6] = { 1, 2, 4, 5, 9 };
	for (int i=0; i < 6; i++) {
		if (mxGetClassID(prhs[intInputs[i]]) != iic) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:intType", "all integer inputs should be of the same type");
		if (mxGetN(prhs[intInputs[i]]) != 1) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:rowVector", "all integer inputs are expected to be co,lumn vectors");
	}

	int dblInputs[5] = { 3, 6, 7, 8, 10 };
	for (int i=0; i < 5; i++) {
		if (!mxIsDouble(prhs[dblInputs[i]])||mxIsComplex(prhs[dblInputs[i]])){
			char *buf = new char[100]();
			sprintf(buf,"Input %d expected to have type (real) double",dblInputs[i]+1);
			mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notDouble", buf);
		}
	}

	if (mxGetM(prhs[8]) != 1) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:rowVector", "V is expected to be a row vector");
	if (!mxIsScalar(prhs[10])) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:notScalar", "The frac input must be scalar");

	// pull together sizes
	intType t, d, n, m;
	t = intType( mxGetScalar(prhs[0]) ); // the total number of cells
	d = mxGetM(prhs[1]); // cell is (d,1)
	n = mxGetN(prhs[3]); // Y is (d,n)
	m = mxGetN(prhs[6]); // X is (d,m)

	// and make sure everything is consistent
	if (mxGetM(prhs[2]) != d) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The sizes of cell and span are inconsistent.");
	if (mxGetM(prhs[3]) != d) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The sizes of cell and Y are inconsistent.");
	if (mxGetM(prhs[4]) != t) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The size of Yhead is inconsistent with total.");
	if (mxGetM(prhs[5]) != n) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The sizes of Y and Ylist are inconsistent.");
	if (mxGetM(prhs[6]) != d) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The sizes of cell and X are inconsistent.");
	if (mxGetNumberOfElements(prhs[7]) != d * d * m) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The size of M is not consistent with the size of X");
	if (mxGetN(prhs[8]) != m) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The size of V is not consistent with the size of X");
	if (mxGetM(prhs[9]) != m) mexErrMsgIdAndTxt("HORACE:cPointsInResolution:dimensions", "The sizes of X and c are inconsistent.");

	// get handles to array inputs
	intType *cells, *spans, *Yhead, *Ylist, *Xcell;
	cells = (intType *)mxGetData(prhs[1]);
	spans = (intType *)mxGetData(prhs[2]);
	Yhead = (intType *)mxGetData(prhs[4]);
	Ylist = (intType *)mxGetData(prhs[5]);
	Xcell = (intType *)mxGetData(prhs[9]);

	double *Y, *X, *M, *V;
	Y = (double *)mxGetData(prhs[3]);
	X = (double *)mxGetData(prhs[6]);
	M = (double *)mxGetData(prhs[7]);
	V = (double *)mxGetData(prhs[8]);

	// get the fractional probability input
	double frac;
	frac = mxGetScalar(prhs[10]);

	// We *could* allocate the first four outputs in MATLAB already, but we'll wait.
	// Just allocate what we actually need to perform the calculations in C.
	intType *nYiX = safealloc<intType>(m);
	intType **allYiX = safealloc<intType *>(m);
	double **allVxR = safealloc<double *>(m);
	intType total_in_resolution=0;
	// Now do the real work!
	total_in_resolution = points_in_resolution(d, cells, spans, n, Y, Yhead, Ylist, m, X, M, V, Xcell, frac, nYiX, allYiX, allVxR);

	// Hard work finished. Now allocate final correct-size output arrays in MATLAB
	// The first four outputs have the same type and size. Allocate ...
	for (int i = 0; i < 4; i++) plhs[i] = mxCreateUninitNumericMatrix(1, m, iic, mxREAL);
	// and get handles to them:
	intType *iX, *nY, *fst, *lst;
	iX = (intType *)mxGetData(plhs[0]);
	nY = (intType *)mxGetData(plhs[1]);
	fst= (intType *)mxGetData(plhs[2]);
	lst= (intType *)mxGetData(plhs[3]);
	// the last two ouputs have equal size but different types
	plhs[4] = mxCreateUninitNumericMatrix(1, total_in_resolution, iic, mxREAL);
	plhs[5] = mxCreateUninitNumericMatrix(1, total_in_resolution, mxDOUBLE_CLASS, mxREAL);
	// their pointers
	intType *matlab_YiX = (intType *)mxGetData(plhs[4]);
	double *matlab_VxR = (double *)mxGetData(plhs[5]);

	for (intType i=0; i<m; i++){
		if (nYiX[i]>n){
			char *buf = new char[100]();
			sprintf(buf,"Pixel %d has more contributing points than possible! (%d vs %d)",i,nYiX[i],n);
			mexErrMsgIdAndTxt("HORACE:cPointsInResolution:overflow",buf);
		}
	}
	
	intType k = 0;
	for (intType i = 0; i < m; i++) {
		// This pixel's index (kept for consistency with MATLAB routine)
		iX[i] = i + 1; // MATLAB-indexing
		// This pixel's first entry in YiX, VxR
		fst[i] = k + 1; // MATLAB-indexing
		// The number of points contributing to this pixel
		nY[i] = nYiX[i]; // copying from C to MATLAB
		// copy output:
		for (intType j = 0; j < nYiX[i]; j++) {
			matlab_YiX[k] = allYiX[i][j]; // do I need to add 1 here?
			matlab_VxR[k] = allVxR[i][j];
			k++;
		}
		// This pixel's last entry in YiX, VxR
		lst[i] = k; // (k-1)   +1 for MATLAB
		// free memory as we go
		delete[] allYiX[i]; delete[] allVxR[i];
	}
	// And free the array-of-array memory
	delete[] allYiX; delete[] allVxR; delete[] nYiX;

	// as a final check, make sure we accumulated all of the point-in-resolution information
	if (k != total_in_resolution) {
		char buffer[120];
		int blen = sprintf(buffer,"Mismatch between expected (%d) and collected (%d) points.",int(total_in_resolution),int(k));
		mexErrMsgIdAndTxt("HORACE:cPointsInResolution:output", buffer);
	}
	//printdbg"mexFunction finished");
}
