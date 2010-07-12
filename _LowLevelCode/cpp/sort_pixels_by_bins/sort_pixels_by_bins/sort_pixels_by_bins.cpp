#include "stdafx.h"
#include "sort_pixels_by_bins.h"
//
const int PIXEL_DATA_WIDTH=9;
enum Input_Arguments{
    Pixel_data,
    Pixel_Indexes,
    Pixel_Distributions,
    N_INPUT_Arguments
};
enum Out_Arguments{
    Pixels_Sorted,
    N_OUTPUT_Arguments
};

//**********************************************************************************************
// the function moves the pixels information into the places which correspond to the cells,
// to which the pixels belong to.
// takes 3 arguments:
// 1 -- array of pixels themself
// 2 --
//**********************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ])
{
  const char REVISION[]="$Revision::      $ ($Date::                                              $)";
  if(nrhs==0&&nlhs==1){
        plhs[0]=mxCreateString(REVISION); 
        return;
  }

  if(nrhs!=N_INPUT_Arguments&&nrhs!=N_INPUT_Arguments-1) {
    std::stringstream buf;
    buf<<"ERROR::sort_pixels_by_bins needs"<<(short)N_INPUT_Arguments<<"  but got "<<(short)nrhs<<" input arguments\n";
    mexErrMsgTxt(buf.str().c_str());
  }
  if(nlhs>N_OUTPUT_Arguments) {
    std::stringstream buf;
    buf<<"ERROR::sort_pixels_by_bins accept only "<<(short)N_OUTPUT_Arguments<<" but requested to return"<<(short)nlhs<<" arguments\n";
    mexErrMsgTxt(buf.str().c_str());
  }

  for(int i=0;i<nrhs;i++){
      if(prhs[i]==NULL){
              std::stringstream buf;
              buf<<"ERROR::sort_pixels_by_bins=> input argument N"<<i+1<<" undefined\n";
              mexErrMsgTxt(buf.str().c_str());
      }
  }

  double  *pPixelData         = (double *)mxGetPr(prhs[Pixel_data]);
  mwSize  nPixDataRows        = mxGetM(prhs[Pixel_data]);
  mwSize  nPixDataCols        = mxGetN(prhs[Pixel_data]);
  const mwSize  *pPixDims     = mxGetDimensions(prhs[Pixel_data]);
  double  *pCellInd      = (double *)mxGetPr(prhs[Pixel_Indexes]);
  double  *pCellDens     = (double *)mxGetPr(prhs[Pixel_Distributions]);
  mwSize distribution_size    = mxGetNumberOfElements(prhs[Pixel_Distributions]);

  plhs[Pixels_Sorted] = mxCreateNumericArray(2,pPixDims, mxDOUBLE_CLASS,mxREAL);
  if(!plhs[Pixels_Sorted]){
      mexErrMsgTxt(" can not allocate memory for output array");
  }
  double * const pPixelSorted = (double *)mxGetPr(plhs[Pixels_Sorted]);
/*
  mwSize  *const ppInd   = new mwSize[distribution_size]; //working array of indexes for transformed pixels
  if(!ppInd){
        mexErrMsgTxt(" can not allocate memory for working array");
  }
*/
  try{
        mwSize  *const ppInd   = (mwSize  *)mxMalloc(distribution_size*sizeof(mwSize )); //working array of indexes for transformed pixels
      
      try{
         sort_pixels_by_bins(pPixelData,nPixDataRows,nPixDataCols,pCellInd,pCellDens,distribution_size,
                         ppInd,pPixelSorted);
       }catch(const char *err){
//	    delete [] ppInd;
        mxFree(ppInd);
        mexErrMsgTxt(err);
       }
       mxFree(ppInd);
  }catch(...){
        mexErrMsgTxt(" can not allocate memory for working array to sort pixels");
  }

//  delete [] ppInd;
}

void sort_pixels_by_bins(double const *const pPixelData,mwSize nDataRows,mwSize nDataCols,double const *const pCellInd,
                         double const *const pCellDens,mwSize distribution_size,
                         mwSize * const ppInd,double *const pPixelSorted){

    mwSize i,j,jBase,ind,i0;
    ppInd[0]=0;
    for(i=1;i<distribution_size;i++){   // calculate the ranges of the cell arrays
        ppInd[i]=ppInd[i-1]+(mwSize)pCellDens[i-1]; // the next cell starts from the the previous one
    };                                              // plus the number of pixels in the cell previous cell
    if(ppInd[distribution_size-1]+pCellDens[distribution_size-1]!=nDataCols){
        throw(" pixels data and their cell distributions are inconsistent ");
    }
//#pragma omp parallel
{
    for(j=0;j<nDataCols;j++){    // sort pixels according to cells
        i0 = j*nDataRows;
        ind = (mwSize)pCellInd[j]-1; // -1 as Matlab arrays start from one;
        jBase=ppInd[ind ]*nDataRows;
        ppInd[ind]++;
        for(i=0;i<nDataRows;i++){  // copy all pixel data into the location requested
            pPixelSorted[jBase+i]=pPixelData[i0+i];
        }
    }
}
}

