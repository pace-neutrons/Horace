#include <iostream>
#include <sstream>
#include <cmath>
#include <time.h>
#include <float.h>
#include <omp.h>

#include <mex.h>
#include <matrix.h>
#include <cfloat>
#include <cstring>
#include <memory>
#include "../../../build_all/OMP_Storage.h"
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

bool bin_pixels(double *s, double *e, double *npix,
                mxArray*  pPixel_data, mxArray* &PixelSorted,
                double const* const cut_range,
                mwSize grid_size[4], int num_threads);


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
//    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalize data
//
//    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalize variance
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
    //
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
    if(nDataRange!=PIX_WIDTH)mexErrMsgTxt("ERROR::bin_pixels-> the pixel data have to be a 9*num_of_pixels array");

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

    bool place_pixels_in_old_array;
    try{
        place_pixels_in_old_array = bin_pixels(pS,pErr,pNpix,pPixData, PixelSorted, pUranges,iGridSizes,num_threads);
    }catch(const char *err){
        mexErrMsgTxt(err);
    }
    //if(!place_pixels_in_old_array){
    //		mxDestroyArray(pPixData);
    //}
    if(place_pixels_in_old_array){
        mexPrintf("WARNING::bin_pixels->not enough memory for working arrays; Pixels sorted in-place");
    }

    mxSetCell(plhs[0],3,PixelSorted);


}
bool bin_pixels(double *s, double *e, double *npix,
                    mxArray*  pPixel_data, mxArray* &PixelSorted,
                    double const* const cut_range,
                    mwSize grid_size[4], int num_threads)
{
    double xt,yt,zt,Et,nPixSq;
    mwSize distribution_size;
    // numbers of the pixels in grid
    distribution_size = grid_size[0]*grid_size[1]*grid_size[2]*grid_size[3];
    // input pixel data and their shapes
    double *pixel_data = mxGetPr(pPixel_data); 
    mwSize data_size   = mxGetN(pPixel_data); 
    mwSize nPixelDatas = mxGetM(pPixel_data); 

    mwSize nPixel_retained(0),nCellOccupied(0);

    std::vector<char> ok(data_size);
    std::vector<mwSize> nGridCell(data_size);
    //  memory to sort pixels according to the grid bins
    std::vector<mwSize >  ppInd(distribution_size);

    bool place_pixels_in_old_array(false); // true does not works properly

    // temporary area for all sorted pixels
    mxArray *tPixelSorted;
    try
    { 
        tPixelSorted  = mxCreateDoubleMatrix(PIX_WIDTH,data_size,mxREAL);
    }catch(...)
    {	
        tPixelSorted=NULL;
        throw("  Can not allocate memory for sorted pixels");
    }
    double *pPixelSorted=mxGetPr(tPixelSorted);


    omp_set_num_threads(num_threads);


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


    std::unique_ptr<omp_storage> pStorHolder(new omp_storage(num_threads, distribution_size, s, e, npix));
    auto pStor = pStorHolder.get();

    std::vector<int> increments(distribution_size,0);

#pragma omp parallel default(none) private(xt,yt,zt,Et,nPixSq) \
    shared(pixel_data,ok,nGridCell,pStor,ppInd,pPixelSorted,increments,s,e,npix,pStorHolder) \
    firstprivate(num_threads,data_size,distribution_size,nDimX,nDimY,nDimZ,nDimE,xBinR,yBinR,zBinR,eBinR) \
    reduction(+:nPixel_retained)
    {
#pragma omp for 
        for(long i=0;i<data_size;i++)
        {
            size_t i0=i*PIX_WIDTH;

            xt = pixel_data[i0+u1];
            yt = pixel_data[i0+u2];
            zt = pixel_data[i0+u3];
            Et = pixel_data[i0+u4];

            //  ok = indx(:,1)>=cut_range(1,1) & indx(:,1)<=cut_range(2,1) & indx(:,2)>=cut_range(1,2) & indx(:,2)<=urange_step(2,2) & ...
            //       indx(:,3)>=cut_range(1,3) & indx(:,3)<=cut_range(2,3) & indx(:,4)>=cut_range(1,4) & indx(:,4)<=cut_range(2,4);
            ok[i]=false;
            if(xt<cut_range[0]||xt>cut_range[1])continue;
            if(xt==cut_range[1])xt*=(1-FLT_EPSILON);
            if(yt<cut_range[2]||yt>cut_range[3])continue;
            if(yt==cut_range[3])yt*=(1-FLT_EPSILON);
            if(zt<cut_range[4]||zt>cut_range[5])continue; 			
            if(zt==cut_range[5])zt*=(1-FLT_EPSILON);
            if(Et<cut_range[6]||Et>cut_range[7])continue; 			
            if(Et==cut_range[7])Et*=(1-FLT_EPSILON);

            nPixel_retained++;

            //ibin(ok) = ibin(ok) + nel(id)*max(0,min((grid_size(id)-1),floor(grid_size(id)*((u(id,ok)-urange(1,id))/(urange(2,id)-urange(1,id))))));

            mwSize ix=(mwSize)floor((xt-cut_range[0])*xBinR);
            mwSize iy=(mwSize)floor((yt-cut_range[2])*yBinR);
            mwSize iz=(mwSize)floor((zt-cut_range[4])*zBinR);
            mwSize ie=(mwSize)floor((Et-cut_range[6])*eBinR);

            mwSize il=ix*nDimX+iy*nDimY+iz*nDimZ+ie*nDimE;

            ok[i]       = true;
            nGridCell[i]= il;


            ////    sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);			
            //#pragma omp atomic   // beware C index one less then Matlab; should use enum instead
            //            s[il]   +=pixel_data[i0+7]; 
            ////    sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
            //#pragma omp atomic
            //            e[il]   +=pixel_data[i0+8];
            //#pragma omp atomic
            //            npix[il]++;
            int n_thread = omp_get_thread_num();
            pStor->add_signal(pixel_data[i0 + 7], pixel_data[i0 + 8],n_thread,il);

        } // end for -- imlicit barrier;
        // combine all thread-calculated distributions together
        if (pStor->is_mutlithreaded)
        {
#pragma omp for
            for (long i = 0; i < distribution_size; i++)
            {
                for (int i0 = 0; i0 < num_threads; i0++)
                {
                    size_t ind = i0*distribution_size + i;
                    s[i] += *(pStor->pSignal + ind);
                    e[i] += *(pStor->pError + ind);
                    npix[i] += *(pStor->pNpix + ind);
                }
            }
        }


        //    sqw_data.s=sqw_data.s./sqw_data.npix;       % normalize data
        //    sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalize variance
#pragma omp for
        for(long i=0;i<distribution_size;i++){
            nPixSq  =npix[i];
            if(nPixSq ==0)nPixSq = 1;
            s[i]   /=nPixSq;
            nPixSq *=nPixSq;
            e[i]   /=nPixSq;
        }

        // sort pixels according to grid cells
        //    ix=find(ok);                % Pixel indices that are included in the grid
        //    [ibin,ind]=sort(ibin(ok));  % ordered bin numbers of the included pixels with index array into the original list of bin numbers of included pixels
        //    ix=ix(ind)';                % Indices of included pixels corresponding to ordered list; convert to column vector
        //    % Sort into increasing bin number and return indexing array
        //    % (treat only the contributing pixels: if the the grid is much smaller than the extent of the data this will be faster)
        //    sqw_data.pix=sqw_data.pix(:,ix);
#pragma omp single
        pStorHolder.release();
        {
            ppInd[0]=0;
            for(long i=1;i<distribution_size;i++){   // initiate the boundaries of the cells to keep pixels
                ppInd[i]=ppInd[i-1]+(mwSize)npix[i-1];
            }; 
        }

        size_t Block_Size = sizeof(*pixel_data)*pix_fields::PIX_WIDTH;


#pragma omp for
        for(long j=0;j<data_size;j++)
        {    
            if(!ok[j])continue;

            size_t nCell = nGridCell[j];       // this is the index of a pixel in the grid cell

            size_t j0;
#ifdef OMP_VERSION_3
    #pragma omp atomic capture
            j0 = ppInd[nCell]++; // each position in a grid cell corresponds to a pixel of the size PIX_WIDTH;
	        j0 *= pix_fields::PIX_WIDTH;
#else
    #pragma omp critical
            j0 = pix_fields::PIX_WIDTH*ppInd[nCell]++; // each position in a grid cell corresponds to a pixel of the size PIX_WIDTH;
#endif


            size_t i0    = j*pix_fields::PIX_WIDTH;
            //memcpy((pPixelSorted+j0),(pixel_data+i0),Block_Size);
            for(size_t i=0;i<pix_fields::PIX_WIDTH;i++){
                pPixelSorted[j0+i]=pixel_data[i0+i];}
        }
    } // end parallel region

    // where to place new pixels
    if (data_size == nPixel_retained){
        PixelSorted = tPixelSorted;
    }
    else{
        try
        { 
            PixelSorted   = mxCreateDoubleMatrix(PIX_WIDTH,nPixel_retained,mxREAL);
        }catch(...)
        {	
            PixelSorted=NULL;
            throw("  Can not allocate memory for sorted pixels");
        }
        // copy pixels info from heap to Matlab controlled memory;
        double *pPixels = mxGetPr(PixelSorted);
        for(size_t i=0;i<nPixel_retained*pix_fields::PIX_WIDTH;i++)
        {
            pPixels[i] = pPixelSorted[i];
        }
        mxDestroyArray(tPixelSorted);
    }
    return place_pixels_in_old_array;
}

#undef OMP_VERSION_3
