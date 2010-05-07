#include "stdafx.h"
//
enum input_arguments{
	Sqw_parameters,
	N_INPUT_Arguments
};
enum arguments_meaning{
   Threads,
   Urange,  
   Grid_size,      
   Pix,
   N_ARGUMENT_CELLS
};
enum out_arguments{
   Signal,
   Error,  
   N_pix,      
   Pix_out,
   N_ARGUMENTS_OUT
};
enum output_arguments{  // not used at the moment
	Sqw_data,
	N_OUTPUT_Arguments
};
#ifdef __GNUC__
#   if __GNUC__ < 4 || (__GNUC__ == 4)&&(__GNUC_MINOR__ < 2)
// then the compiler does not undertand OpenMP functions, let's define them
void omp_set_num_threads(int nThreads){};
#define omp_get_num_threads() 1
#define omp_get_max_threads() 1
#define omp_get_thread_num()  0
#   endif
#endif

bool accumulate_cut(double *s, double *e, double *npix,
					mxArray*  pPixel_data, mxArray* &PixelSorted,
					double const* const cut_range,
					mwSize grid_size[4], int num_threads);

const int PIXEL_DATA_WIDTH=9;
//
void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ])
//*************************************************************************************************
// the function (bin_pixels_c) distributes pixels according to the 4D-grid specified and
// calculates signal and error within grid cells
// usage:
// >>> bin_pixels_c(sqw_data,urange,grid_size);
// where sqw_data -- sqw structure with defined array of correct pixels data
// urange         -- allowed range of the pixels; the pixels which are out of the range are rejected
// grid_size      -- integer array of the grid dimensions in every 4 directions
//*************************************************************************************************
// Matlab code:
//    % Reorder the pixels according to increasing bin index in a Cartesian grid->
//    [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
//    % transform pixels;
//    sqw_data.pix=sqw_data.pix(:,ix);
//    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
//    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
//    sqw_data.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
//    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalise data
//
//    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalise variance
//    clear ix ibin   % biggish arrays no longer needed
//    nopix=(sqw_data.npix==0);
//    sqw_data.s(nopix)=0;
//    sqw_data.e(nopix)=0;
// based on original % Original matlab code of : T.G.Perring
//
{
  mwSize  iGridSizes[4],     // array of grid sizes
          totalGridSize(1),  // number of cells in the whole grid;
		  nGridDimensions,    // number of dimension in the whole grid (usually 4 according to the pixel data but can be modified in a future
          i;
  double *pS,*pErr,*pNpix;   // arrays for the signal, error and number of pixels in a cell (density);
  mxArray *PixelSorted;

  const char REVISION[]="$Revision::      $ ($Date::                                              $)";
  if(nrhs==0&&nlhs==1){
		plhs[0]=mxCreateString(REVISION); 
		return;
  }


  if(nrhs!=N_INPUT_Arguments) {
    std::stringstream buf;
	buf<<"ERROR::bin_pixels needs"<<(short)N_INPUT_Arguments<<"  but got "<<(short)nrhs<<" input arguments\n";
	mexErrMsgTxt(buf.str().c_str());
  }
//  if(nlhs>N_OUTPUT_Arguments) {
//    std::stringstream buf;
//	buf<<"ERROR::bin_pixels accepts only "<<(short)N_OUTPUT_Arguments<<" but requested to return"<<(short)nlhs<<" arguments\n";
//    mexErrMsgTxt(buf.str().c_str());
//  }
  if(!mxIsCell(prhs[Sqw_parameters])){
		mexErrMsgTxt("ERROR::bin_pixels function needs to receive its parameters as a cell array\n");
  }
  size_t nPars        =  mxGetN(prhs[Sqw_parameters]);

  if (nPars!=N_ARGUMENT_CELLS){
    std::stringstream buf;
	buf<<"ERROR::bin_pixels expexts array of "<<(short)N_ARGUMENT_CELLS; 
	buf<<"cells \n but got "<<(short)nPars<<" cells\n";
	mexErrMsgTxt(buf.str().c_str());
  }


  int num_threads(1);
  mxArray *pThreads = mxGetCell(prhs[Sqw_parameters], Threads);
  if(pThreads){
		num_threads=(int)*mxGetPr(pThreads);
  }else{
		num_threads = 1;
		mexPrintf("WARNING::bin_pixels->can not retrieve the number of computational threads from calling workspace, 1 assumed");
 }

  double const *const pGrid_sizes    = (double *)mxGetPr(mxGetCell(prhs[Sqw_parameters], Grid_size));
  double const *const pUranges       = (double *)mxGetPr(mxGetCell(prhs[Sqw_parameters], Urange));
  nGridDimensions                    = mxGetN(mxGetCell(prhs[Sqw_parameters], Grid_size));
  if(nGridDimensions>4)mexErrMsgTxt(" we do not currently work with the grids which have more then 4 dimensions");

  for(i=0;i<nGridDimensions;i++){
	  iGridSizes[i]=(mwSize)(pGrid_sizes[i]);
	  totalGridSize*=iGridSizes[i];
  }
//**************************************************************
  // get pixels information
  mxArray* const pPixData    = mxGetCell(prhs[Sqw_parameters], Pix);
  if(!pPixData)mexErrMsgTxt("ERROR::bin_pixels-> pixels information (last field of input data) can not be void");
  // this field has to had the format specified;
  mwSize  nPixels             = mxGetN(pPixData);
  mwSize  nDataRange          = mxGetM(pPixData);
  if(nDataRange!=9)mexErrMsgTxt("ERROR::bin_pixels-> the pixel data have to be a 9*num_of_pixels array");

  // 
  plhs[0] = mxCreateCellMatrix(1,N_ARGUMENTS_OUT);
  if(!plhs[0]){mexErrMsgTxt("ERROR::bin_pixels-> can not allocate cell array for output parameters");
  }

  mxArray* tt;
  for(i=0;i<N_ARGUMENTS_OUT-1;i++){
			tt=mxCreateNumericArray(nGridDimensions,iGridSizes,mxDOUBLE_CLASS,mxREAL);
			if (!tt)mexErrMsgTxt("ERROR::bin_pixels->can not allocate memory for output signals errors and npixels");
			mxSetCell(plhs[0],i,tt);
  }

  pS   = (double *)mxGetPr(mxGetCell(plhs[0],Signal));
  pErr = (double *)mxGetPr(mxGetCell(plhs[0],Error));
  pNpix= (double *)mxGetPr(mxGetCell(plhs[0],N_pix));

  for (i=0;i<totalGridSize;i++){
    *(pS+i)   =0;
    *(pErr+i) =0;
    *(pNpix+i)=0;
  }


  bool place_pixels_in_old_array = accumulate_cut(pS,pErr,pNpix,pPixData, PixelSorted, pUranges,iGridSizes,num_threads);
  //if(!place_pixels_in_old_array){
  //		mxDestroyArray(pPixData);
  //}
  if(place_pixels_in_old_array){
     mexPrintf("WARNING::bin_pixels->not enough memory for working arrays; Pixels sorted in-place");
  }

  mxSetCell(plhs[0],3,PixelSorted);


}

bool accumulate_cut(double *s, double *e, double *npix,
					mxArray*  pPixel_data, mxArray* &PixelSorted,
					double const* const cut_range,
					mwSize grid_size[4], int num_threads)
{
double xt,yt,zt,Et,nPixSq;
long i,j;
mwSize ix,iy,iz,ie,il;
mwSize i0,j0,distribution_size;
// numbers of the pixels in grid
distribution_size = grid_size[0]*grid_size[1]*grid_size[2]*grid_size[3];
// input pixel data and their shapes
double *pixel_data = mxGetPr(pPixel_data); 
mwSize data_size   = mxGetN(pPixel_data); 
mwSize nPixelDatas = mxGetM(pPixel_data); 

mwSize nPixel_retained(0),nCellOccupied(0);
char *ok;
mwSize *nGridCell;
//
try{         	ok = new char[data_size];
}catch(...){ 	throw(" Can not allocate auxiliary memory for the selectors of the retained pixels");
}
try{         	nGridCell	= new mwSize[data_size]; // grid indexes of the retainde pixels
}catch(...){	delete [] ok;
	            throw(" Can not allocate auxiliary memory for the grid indexes of the retainde pixels");
}


omp_set_num_threads(num_threads);
int numRealThreads=omp_get_max_threads();

int PIXEL_data_width=(int)nPixelDatas;
double  xBinR,yBinR,zBinR,eBinR;                 // new bin sizes in four dimensins 
mwSize  nDimX(0),nDimY(0),nDimZ(0),nDimE(0); // reduction dimensions; if 0, the dimension is reduced;

//       nel=[1,cumprod(grid_size)]; % Number of elements per unit step along each dimension
mwSize      nDimLength(1);
nDimX      =nDimLength;    nDimLength*=grid_size[0];
nDimY      =nDimLength;    nDimLength*=grid_size[1];
nDimZ      =nDimLength;    nDimLength*=grid_size[2];
nDimE      =nDimLength;    
//
xBinR       = grid_size[0]/(cut_range[1]-cut_range[0]);
yBinR       = grid_size[1]/(cut_range[3]-cut_range[2]);
zBinR       = grid_size[2]/(cut_range[5]-cut_range[4]);
eBinR       = grid_size[3]/(cut_range[7]-cut_range[6]);


#pragma omp parallel default(none), private(i,i0,xt,yt,zt,Et,ix,iy,iz,ie,il,nPixSq), \
	 shared(pixel_data,ok,nGridCell,s,e,npix), \
	 firstprivate(nPixelDatas,data_size,distribution_size,nDimX,nDimY,nDimZ,nDimE,xBinR,yBinR,zBinR,eBinR), \
	 reduction(+:nPixel_retained)
{
//	#pragma omp master
//{
//    nRealThreads= omp_get_num_threads();
//	 mexPrintf(" n real threads %d :\n",nRealThread);}

#pragma omp for schedule(static,10)
	for(i=0;i<data_size;i++){
			i0=i*nPixelDatas;

			xt = pixel_data[i0];
			yt = pixel_data[i0+1];
			zt = pixel_data[i0+2];
			Et = pixel_data[i0+3];

//  ok = indx(:,1)>=cut_range(1,1) & indx(:,1)<=cut_range(2,1) & indx(:,2)>=cut_range(1,2) & indx(:,2)<=urange_step(2,2) & ...
//       indx(:,3)>=cut_range(1,3) & indx(:,3)<=cut_range(2,3) & indx(:,4)>=cut_range(1,4) & indx(:,4)<=cut_range(2,4);
			ok[i]=false;
			if(xt<cut_range[0]||xt>=cut_range[1])continue;
			if(yt<cut_range[2]||yt>=cut_range[3])continue;
			if(zt<cut_range[4]||zt>=cut_range[5])continue; 			
			if(Et<cut_range[6]||Et>=cut_range[7])continue; 			

			nPixel_retained++;

         //ibin(ok) = ibin(ok) + nel(id)*max(0,min((grid_size(id)-1),floor(grid_size(id)*((u(id,ok)-urange(1,id))/(urange(2,id)-urange(1,id))))));

			ix=(mwSize)floor((xt-cut_range[0])*xBinR);
			iy=(mwSize)floor((yt-cut_range[2])*yBinR);
			iz=(mwSize)floor((zt-cut_range[4])*zBinR);
			ie=(mwSize)floor((Et-cut_range[6])*eBinR);

			il=ix*nDimX+iy*nDimY+iz*nDimZ+ie*nDimE;

			ok[i]       = true;
			nGridCell[i]= il;


//    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);			
#pragma omp atomic   // beware C index one less then Matlab; should use enum instead
			s[il]   +=pixel_data[i0+7]; 
//    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
#pragma omp atomic
			e[il]   +=pixel_data[i0+8];
#pragma omp atomic
			npix[il]++;

	} // end for -- imlicit barrier;

//    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalise data
//    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalise variance
#pragma omp for
	for(i=0;i<distribution_size;i++){
		nPixSq  =npix[i];
		if(nPixSq ==0)nPixSq = 1;
		s[i]   /=nPixSq;
		nPixSq *=nPixSq;
		e[i]   /=nPixSq;
	}
} // end parallel region

// sort pixels according to the grid bins
mwSize *ppInd;
try{
    ppInd = new mwSize[distribution_size];
}catch(...){
	delete [] nGridCell;
	delete [] ok;
	throw("  Can not allocate auxiliary memory for grid indexes boundaries");
}
// where to place new pixels
	try{      		PixelSorted   = mxCreateDoubleMatrix(nPixelDatas,nPixel_retained,mxREAL);
	}catch(...){	PixelSorted=NULL;
	}
	bool place_pixels_in_old_array(false);
	if(!PixelSorted){              // replace pixels in-place 
		//PixelSorted=mxCreateSharedDataCopy(pPixel_data);
		PixelSorted              =pPixel_data;
		place_pixels_in_old_array=true;
	}
	double *pPixelSorted=mxGetPr(PixelSorted);


// sort pixels according to grid cells
//    ix=find(ok);                % Pixel indicies that are included in the grid
//    [ibin,ind]=sort(ibin(ok));  % ordered bin numbers of the included pixels with index array into the original list of bin numbers of included pixels
//    ix=ix(ind)';                % Indicies of included pixels coerresponding to ordered list; convert to column vector
//    % Sort into increasing bin number and return indexing array
//    % (treat only the contributing pixels: if the the grid is much smaller than the extent of the data this will be faster)
//    sqw_data.pix=sqw_data.pix(:,ix);

	ppInd[0]=0;
	for(i=1;i<distribution_size;i++){   // initiate the boudaries of the cells to keep pixels
			ppInd[i]=ppInd[i-1]+(mwSize)npix[i-1];
	}; 
	//double *buf =(double *)mxMalloc(nPixelDatas*numRealThreads*sizeof(double));
	double buf[PIXEL_DATA_WIDTH];

	mwSize nCell,pCellFree,tnCell,ic;
	int lastFreeCell(numRealThreads);

    bool swap;
	if(place_pixels_in_old_array){	
{

// 		ic          = omp_get_thread_num();
	 	ic          = 0;
		swap        = false;
		while(ic<data_size){
			if(!ok[ic]){
//#pragma omp critical
				{	ic=lastFreeCell;
				    lastFreeCell++;
				}
				continue;
			}
//#pragma omp critical
			{	
				ok[ic]   = 2 ;              // mark this cell as occupied by a thread
				nCell    = nGridCell[ic];  // number of the cell where the pixel is 
			    pCellFree= ppInd[nCell];   // pointer to the free memory in this cell
			    ppInd[nCell]++;           // adjust the counter of the "free" memory in this cell as old will be occupied		
			}
			if(ic == pCellFree){     // pixel already in the right cell, rigth place, move on
				ok[ic]=false;
				continue;
			}
			//if(ok[pCellFree]==2){  // the cell is already dealt with by abither thread
			//}
			// swap(pixel at ic with pixel at pCellFree=ppInd[GridCell[ic]])************************
			//(1)
			if(ok[pCellFree]){  // the destination cell already has a valid pixel which should be saved
				for(i=0;i<nPixelDatas;i++){	buf[i]= pixel_data[pCellFree*nPixelDatas+i];}
				// tOk  = ok[pCellFree]; always true;
				tnCell = nGridCell[pCellFree];
				swap = true;
			}
			//(2)      // copy current pixel into the new location
			for(i=0;i<nPixelDatas;i++){	pixel_data[pCellFree*nPixelDatas+i]=pixel_data[ic*nPixelDatas+i];}
			  ok[pCellFree]       = false; // make it false to not touch it any more
			 //nGridCell[pCellFree]= nGridCell[ic]; // this is for checks only
            // (3)
			if(swap){   // return the pixel just saved into the array of unprocessed pixels on the place of the pixel just processed 
				//memcpy((char *)(pixel_data+ic*nPixelDatas),buf,pixel_Byte_size);			 
				for(i=0;i<nPixelDatas;i++){pixel_data[ic*nPixelDatas+i]=buf[i];}
				// ok[ic]        = tOk; always true
				nGridCell[ic] = tnCell;
				swap=false;
			}
			//*end swap*********************************************************
		}
} // end parallel region;

	}else{
#pragma omp parallel  default(none),private(i,j,i0,j0,nCell) \
		shared(ppInd,pPixelSorted,ok,nGridCell,pixel_data), \
		firstprivate(data_size,nPixelDatas)
{
#pragma omp for
		for(j=0;j<data_size;j++){    
			if(!ok[j])continue;

			nCell = nGridCell[j];            // this is the index of a pixel in the grid cell
			j0    = ppInd[nCell]*nPixelDatas; // each one position in a grid cell corresponds to a pixel of the size nPixelDatas
			i0    = j*nPixelDatas;
#pragma omp atomic
			ppInd[nCell]++;

			//memcpy((char *)(pPixelSorted+jBase),(char *)(pixel_data+j*nPixelDatas),pixel_Byte_size);
			 for(i=0;i<nPixelDatas;i++){
				 pPixelSorted[j0+i]=pixel_data[i0+i];}
		}
} // end parallel region
	} // else if

	delete [] ppInd;
    delete [] ok;
    delete [] nGridCell;
	//mxFree(buf);

	return place_pixels_in_old_array;
}
