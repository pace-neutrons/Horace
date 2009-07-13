// accumulate_cut.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "accumulate_cut.h"
enum InputArguments {
	Pixel_data,
	CoordRotation_matrix,
	CoordShif_matrix,
	Scale_energy,
	Shift_energy,
	DataCut_range,
	Ignore_Nan,
	Ignore_Inf,
	N_Parallel_Processes,
	N_INPUT_Arguments
};
enum OutputArguments{
	Pixels_Ok,
	Pixels_Transformed,
	Actual_Pix_Range,
	NUM_Pix_Retained,
	N_OUTPUT_Arguments
};


const int PIXEL_DATA_WIDTH=9;
const int OUT_PIXEL_DATA_WIDTH=4;

void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ]){ 

//function [*ok,*dPixInd] = accumulate_cut (npix, urange_step_pix, keep_pix,...
//                                                      pixel_data, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)

   int n_Parallel_Threads;
 
  /* Check for proper number of arguments. */
  if((nrhs!=	N_INPUT_Arguments)&&(nrhs!=	N_INPUT_Arguments-1)) {
    mexErrMsgTxt("Wrong number of input arguments");
  } else if(nlhs>N_OUTPUT_Arguments) {
    mexErrMsgTxt("Too many output arguments requested");
  }
  
// inputs:

  double const *pPixelData    = (double *)mxGetPr(prhs[Pixel_data]);
  mwSize  nPixDataRows  = mxGetM(prhs[Pixel_data]); 
  mwSize  nPixDataCols  = mxGetN(prhs[Pixel_data]);
  if(pPixelData==NULL){
	  mexPrintf("Accomulate cut: No input data, nothibng to do\n");
	  return ;
  }
  if(nPixDataRows!=PIXEL_DATA_WIDTH){
	  mexErrMsgTxt("Pixel data has to be a 9xN matrix where 9 is the number of pixels' data and N -- number of pixels");
  }
  double const*rot_matrix = 	(double *)mxGetPr(prhs[CoordRotation_matrix]);
  if(mxGetM(prhs[CoordRotation_matrix])!=3||mxGetN(prhs[CoordRotation_matrix])!=3){
	  mexErrMsgTxt(" Coordinates Rotation has to be a 3x3 matrix");
  }
  double *shift_matrix = (double *)mxGetPr(prhs[CoordShif_matrix]);
  if(mxGetM(prhs[CoordShif_matrix])!=3||mxGetN(prhs[CoordShif_matrix])!=1){
	  mexErrMsgTxt(" Coordinates shift has to be a 1x3 matrix");
  }
  double ebin = *mxGetPr(prhs[Scale_energy]);
  if(mxGetM(prhs[Scale_energy])!=1||mxGetN(prhs[Scale_energy])!=1){
	  mexErrMsgTxt(" Energy scale has to be a scalar");
  }
  double e_shift = *mxGetPr(prhs[Shift_energy]);
  if(mxGetM(prhs[Shift_energy])!=1||mxGetN(prhs[Shift_energy])!=1){
	  mexErrMsgTxt(" Energy shift has to be a scalar");
  }
  double *data_limits = mxGetPr(prhs[DataCut_range]);
  if(mxGetM(prhs[DataCut_range])!=2||mxGetN(prhs[DataCut_range])!=OUT_PIXEL_DATA_WIDTH){
	  mexErrMsgTxt(" Data range has to be a 2x4 matrix");
  }

  bool ignore_Nan(false);
  if(*mxGetPr(prhs[Ignore_Nan])>0){	  ignore_Nan=true;
  }
  bool ignore_Inf(false);
  if(*mxGetPr(prhs[Ignore_Inf])>0){	  ignore_Inf=true;
  }
  n_Parallel_Threads=1;
  if(nrhs==N_INPUT_Arguments){
		n_Parallel_Threads=(int)(*mxGetPr(prhs[N_Parallel_Processes]));
  }


  /* Create matrix for the return argument. */
  mwSize dims[2];
  dims[0]=1;
  dims[1]=nPixDataCols;
  plhs[Pixels_Ok] =mxCreateLogicalArray(2,dims);
  mxLogical *ok = (mxLogical *)mxGetPr(plhs[Pixels_Ok]);
  if(!plhs[Pixels_Ok]){
	  mexErrMsgTxt(" Can not allocate memory for pixel validity array\n");
  }
//  plhs[Pixels_Transformed]= mxCreateDoubleMatrix(4,nPixDataCols, mxREAL);
//  if(!plhs[Pixels_Transformed]){
//	  mexErrMsgTxt(" Can not allocate memory for transformed pixels matrix\n");
//  }
  
  plhs[Actual_Pix_Range]= mxCreateDoubleMatrix(2,4, mxREAL);
  if(!plhs[Actual_Pix_Range]){
	  mexErrMsgTxt(" Can not allocate memory for actual pixel range matrix\n");
  }
  plhs[NUM_Pix_Retained]=mxCreateDoubleMatrix(1,1, mxREAL);

  double *pnPixel_retained = (double *)mxGetPr(plhs[NUM_Pix_Retained]);
  mwSize nPixel_retained(0);

  accumulate_cut(ok,plhs[Pixels_Transformed],mxGetPr(plhs[Actual_Pix_Range]),nPixel_retained,
	             pPixelData,nPixDataCols,
				 rot_matrix ,shift_matrix,ebin,e_shift, data_limits,ignore_Nan,ignore_Inf,n_Parallel_Threads);
  *pnPixel_retained = (double)nPixel_retained;

}


void accumulate_cut(mxLogical *ok,mxArray *&final_pix_transformed,double *actual_pix_range,mwSize &nPixel_retained,
					double const* pixel_data,mwSize data_size,
					double const* rot_ustep,double const* trans_bott_left,double ebin,double trans_elo, // transformation matrix
					double const* cut_range, bool ignore_nan,bool ignore_inf, // drop pixel conditions;
					int num_OMP_Threads)
{
/*
function [npix, cut_range_pix, npix_retain, ok] = accumulate_cut (npix, cut_range_pix, keep_pix,...
                                                     pixel_data, cut_range, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
% Syntax:
%   >> [npix,npix_retain] = accumulate_cut (npix, v, cut_range, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argumnet with same name exists - exploits in-place working of Matlab R2007a)
% * actual_pix_range Actual range of contributing pixels
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   pixel_data(9,:) u1,u2,u3,u4,irun,idet,ien,s,e for each pixel, where ui are coords in projection axes of the pixel data in the file
%   cut_range     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%
% Output:
%   npix            Array of number of contributing pixels
%   actual_pix_range Actual range of contributing pixels
%   nPixel_retained Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

                 38 % T.G.Perring   19 July 2007; C-version Alex Buts 02 July 2009
*/

double xt,yt,zt,Et,INF(0),NAN(0),
       pix_Xmin,pix_Ymin,pix_Zmin,pix_Emin,pix_Xmax,pix_Ymax,pix_Zmax,pix_Emax;
double ebin_inv(1/ebin);

//int nRealThreads;
long i;
unsigned long nPixel_retainedLoc;
mwSize j0,i0;

bool   transform_energy,ignore_something,ignote_all;
//% Catch special (and common) case of energy being an integration axis to save calculations 
if(abs(ebin-1)<DBL_EPSILON && abs(trans_elo)<DBL_EPSILON){   	transform_energy=false;
}else{ 															transform_energy=true;
}
ignore_something=ignore_nan|ignore_inf;
ignote_all      =ignore_nan&ignore_inf;

if(ignore_nan){ 	NAN=mxGetNaN(); 
}
if(ignore_inf){  	INF=mxGetInf(); 
}
nPixel_retained = 0;
nPixel_retainedLoc=0;
mxArray *tmp               = mxCreateDoubleMatrix(4,data_size,mxREAL); //actually working array of transformed pixels
double *pPixel_transformed = mxGetPr(tmp);              // and this is its array itself
// min-max value initialization
actual_pix_range[0]=actual_pix_range[2]=actual_pix_range[4]=actual_pix_range[6]=std::numeric_limits<double>::max();
actual_pix_range[1]=actual_pix_range[3]=actual_pix_range[5]=actual_pix_range[7]=-actual_pix_range[0];
pix_Xmin=pix_Ymin=pix_Zmin=pix_Emin=std::numeric_limits<double>::max();
pix_Xmax=pix_Ymax=pix_Zmax=pix_Emax=-actual_pix_range[0];


omp_set_num_threads(num_OMP_Threads);

#pragma omp parallel default(none), private(i,i0,j0,xt,yt,zt,Et), \
	 shared(actual_pix_range,pixel_data,rot_ustep,trans_bott_left,cut_range,ok,pPixel_transformed, \
	 data_size,ignote_all,ignore_nan,ignore_inf,ignore_something,transform_energy, \
     NAN,INF,PIXEL_DATA_WIDTH,OUT_PIXEL_DATA_WIDTH ), \
	 firstprivate(pix_Xmin,pix_Ymin,pix_Zmin,pix_Emin, pix_Xmax,pix_Ymax,pix_Zmax,pix_Emax,\
				  trans_elo,ebin_inv), \
	 reduction(+:nPixel_retainedLoc)
{
//	#pragma omp master
//{
//    nRealThreads= omp_get_num_threads()
//	 mexPrintf(" n real threads %d :\n",nRealThread);}

#pragma omp for schedule(static,1)
	for(i=0;i<data_size;i++){
			j0=i*PIXEL_DATA_WIDTH;
			i0=i*OUT_PIXEL_DATA_WIDTH;

      // Check for the case when either data.s or data.e contain NaNs or Infs, but data.npix is not zero.
      // and handle according to options settings.
			if(ignore_something){
				ok[i]=true;
				if(ignote_all){
					if(pixel_data[j0+7]==INF||pixel_data[j0+7]==NAN||
					pixel_data[j0+8]==INF||pixel_data[j0+8]==NAN){
							ok[i]=false;
							continue;
					}
				}else if(ignore_nan){
					if(pixel_data[j0+7]==NAN||pixel_data[j0+8]==NAN){
						ok[i]=false;
						continue;
					}
				}else if(ignore_inf){
					if(pixel_data[j0+7]==INF||pixel_data[j0+8]==INF){
						ok[i]=false;
						continue;
					}
				}
			}

      // Transform the coordinates u1-u4 into the new projection axes, if necessary
	  //    indx=[(v(1:3,:)'-repmat(trans_bott_left',[size(v,2),1]))*rot_ustep',v(4,:)'];  % nx4 matrix 
			xt=pixel_data[j0  ]-trans_bott_left[0];
			yt=pixel_data[j0+1]-trans_bott_left[1];
			zt=pixel_data[j0+2]-trans_bott_left[2];

			if(transform_energy){
			//    indx(4)=[(v(4,:)'-trans_elo)*(1/ebin)];  % nx4 matrix
				Et=(pixel_data[j0+3]-trans_elo)*ebin_inv;
			}else{
//% Catch special (and common) case of energy being an integration axis to save calculations 
			//  indx(4)=[(v(4,:)'];  % nx4 matrix
				Et=pixel_data[j0+3];
			}

//  ok = indx(:,1)>=cut_range(1,1) & indx(:,1)<=cut_range(2,1) & indx(:,2)>=cut_range(1,2) & indx(:,2)<=urange_step(2,2) & ... 
//       indx(:,3)>=cut_range(1,3) & indx(:,3)<=cut_range(2,3) & indx(:,4)>=cut_range(1,4) & indx(:,4)<=cut_range(2,4);
			if(Et<cut_range[6]||Et>cut_range[7]){ ok[i]=false;		continue;
			}else{                                ok[i]=true;
			}

    		xt=xt*rot_ustep[0]+yt*rot_ustep[1]+zt*rot_ustep[2];
			if(xt<cut_range[0]||xt>cut_range[1]){ ok[i]=false;		continue;
			}else{									 
			}

			yt=xt*rot_ustep[3]+yt*rot_ustep[4]+zt*rot_ustep[5];
			if(yt<cut_range[2]||yt>cut_range[3]){ ok[i]=false;		continue;
			}

			zt=xt*rot_ustep[6]+yt*rot_ustep[7]+zt*rot_ustep[8];
			if(zt<cut_range[4]||zt>cut_range[5]){ ok[i]=false;		continue;
			}else{                                         			nPixel_retainedLoc++;
			}



//     indx=indx(ok,:);    % get good indices (including integration axes and plot axes with only one bin) 
			pPixel_transformed[i0  ]=xt;
			pPixel_transformed[i0+1]=yt;
			pPixel_transformed[i0+2]=zt;
			pPixel_transformed[i0+3]=Et;
	//	i0=nPixel_retained*OUT_PIXEL_DATA_WIDTH;    // transformed pixels;
//
//
//    actual_pix_range = [min(actual_pix_range(1,:),min(indx,[],1));max(actual_pix_range(2,:),max(indx,[],1))];  % true range of data 
			if(xt<pix_Xmin)pix_Xmin=xt;
			if(xt>pix_Xmax)pix_Xmax=xt;

			if(yt<pix_Ymin)pix_Ymin=yt;
			if(yt>pix_Ymax)pix_Ymax=yt;

			if(zt<pix_Zmin)pix_Zmin=zt;
			if(zt>pix_Zmax)pix_Zmax=zt;

			if(Et<pix_Emin)pix_Emin=Et;
			if(Et>pix_Emax)pix_Emax=Et;

	} // end for -- imlicit barrier;
#pragma omp critical
	{
		if(actual_pix_range[0]>pix_Xmin)actual_pix_range[0]=pix_Xmin;
		if(actual_pix_range[2]>pix_Ymin)actual_pix_range[2]=pix_Ymin;
		if(actual_pix_range[4]>pix_Zmin)actual_pix_range[4]=pix_Zmin;
		if(actual_pix_range[6]>pix_Emin)actual_pix_range[6]=pix_Emin;

		if(actual_pix_range[1]<pix_Xmax)actual_pix_range[1]=pix_Xmax;
		if(actual_pix_range[3]<pix_Ymax)actual_pix_range[3]=pix_Ymax;
		if(actual_pix_range[5]<pix_Zmax)actual_pix_range[5]=pix_Zmax;
		if(actual_pix_range[7]<pix_Emax)actual_pix_range[7]=pix_Emax;
	}
} // end parallel region
nPixel_retained      =nPixel_retainedLoc;

// 
if(nPixel_retained==0){
	 final_pix_transformed= mxCreateDoubleMatrix(0,0,mxREAL); // allocate empty matrix and 
	 data_size=0;                                     // set data size to skip the following loops
}else{
	 final_pix_transformed= mxCreateDoubleMatrix(nPixel_retained,OUT_PIXEL_DATA_WIDTH,mxREAL);
}
if(!final_pix_transformed){ // can not allocate memory for reduction; but all data are there -- can do everything in serial fashion
    mexErrMsgTxt(" Can not allocate memory for the transformed pixels");
	return;
}

long ic(0);
double *pFin_pix=mxGetPr(final_pix_transformed);
long j1(nPixel_retained);
long j2(2*nPixel_retained);
long j3(3*nPixel_retained);
// indx=indx(ok,:);    % get good indices (including integration axes and plot axes with only one bin)
#pragma omp parallel default(none), private(i,i0), \
	       shared(ic,ok,pFin_pix,pPixel_transformed, \
           data_size,OUT_PIXEL_DATA_WIDTH), \
           firstprivate(j1,j2,j3)
{
#pragma omp for 
for (i=0;i<data_size;i++){
		i0=i*OUT_PIXEL_DATA_WIDTH;

		if(ok[i]){
			pFin_pix[   ic]=pPixel_transformed[i0  ];
			pFin_pix[j1+ic]=pPixel_transformed[i0+1];
			pFin_pix[j2+ic]=pPixel_transformed[i0+2];
			pFin_pix[j3+ic]=pPixel_transformed[i0+3];
#pragma omp atomic
				ic++;
			}
} // end for
} // end parallel;
mxDestroyArray(tmp);
}
/*
0.25       2   79 indx = indx(:,pax); % Now keep only the plot axes with at least two bins 
< 0.01       2   80 if ~isempty(pax)        % there is at least one plot axis with two or more bins 
  0.23       2   81     indx=ceil(indx);    % indx contains the bin index for the plot axes (one row per pixel) 
  0.09       2   82     indx(indx==0)=1;    % make sure index is between 1 and n 
  0.62       2   83     s    = s    + accumarray(indx, v(8,ok), size(s)); 
  0.61       2   84     e    = e    + accumarray(indx, v(9,ok), size(s)); 
  0.39       2   85     npix = npix + accumarray(indx, ones(1,size(indx,1)), size(s)); 
             2   86     npix_retain = length(indx); 
                 87     % If keeping the information about individual pixels, get that information and single index into the column representation
             2   88     if keep_pix 
             2   89         ixcell=cell(1,length(pax)); % cell array that will contain the indices for each plot axis (as required by matlab function sub2ind) 
             2   90         for i=1:length(pax) 
  0.13       6   91             ixcell{i}=indx(:,i); 
< 0.01       6   92         end 
  0.36       2   93         ix=sub2ind(size(s),ixcell{:});  % column vector of single index of the retained pixels 
                 94     else
                 95         ok=[];  % set to empty array
                 96         ix=[];
                 97     end
                 98 else
                 99     s    = s    + sum(v(8,ok));
                100     e    = e    + sum(v(9,ok));
                101     npix = npix + size(indx,1);
                102     npix_retain = sum(ok(:));
                103     if keep_pix
                104         ix=ones(npix_retain,1);         % all retained pixels go into the one and only bin, by definition
                105     else
                106         ok=[];  % set to empty array
                107         ix=[];
                108     end
                109 end
*/