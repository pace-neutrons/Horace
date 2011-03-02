// calc_projections_c.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include "calc_projections_c.h"

#ifdef __GNUC__
#   if __GNUC__ <= 4
#		 if __GNUC_MINOR__ < 2  // then the compiler do not undertand OpenMP functions, let's define them
void omp_set_num_threads(int nThreads){};
int  omp_get_num_threads(void){};
#		endif
#	endif
#endif

// ebumerate input patameters for easy references. 
enum inPar{
    Spec_to_proj,
    Data,
    Detectors,
    nEfix,
    nK_to_e,
    nEmode,
    nNThreads,
    NUM_IN_args
};


//============================================================================================
//**
//> the function transforms the detector positions from the instrtumental to the crystal system of coordinates
//
// usage:
// ucoordinates=calc_projections_c(transf_matrix,data,detectors);
//
// input parameters:
// transf_matrix -- 3x3 rotational(Sp=1) matrix of transformation from device coordinates to the
//                   crystal coordinated
// data          -- structure with the data from experiment, has to have fields in accordence with the
//                  enum dataStructure above; The program uses the field data.energy --an array of 1xnEnergy values
//
// detectors     -- structure with the data, which describes the detector positions with the field,
//                  accordingly to enum detectorsStructure
//                  the program uses the fields phi and psi which should be a 1xnDetectors arrays
// efix          -- Fixed energy (meV)
// k_to_e        -- constant to transform the neutron wave-vector into the incident neutron energy
// emode         -- Direct geometry=1, indirect geometry=2, elastic=0
//% ***               only mode 1 is currently supported thourn others can be enabled in a future. 
// nThreads      -- number of threads to use to run the program.
//
// Outputs:
// ucoordinates  -- 4xn_data*nEnergies vector of the signal and energies in the transformed coordinates
//<
//============================================================================================

//* Possible prototipe for a generic function
double getMatlabScalar(const mxArray *pPar,const char * const fieldName){
    if(pPar==NULL){
        mexErrMsgTxt(" The parameter has to be defined");
    }
    if(mxGetM(pPar)!=1||mxGetN(pPar)!=1){
        std::stringstream buf;
        buf<<*fieldName<< " has to be a scalar\n";
        mexErrMsgTxt(buf.str().c_str());
    }
    return (double)*mxGetPr(pPar);
};


void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ])
{
   unsigned int eMode(1),nThreads(1),i;
    size_t nDataPoints,nEnShed;
    mwSize nDetectors,nEnergies;
    double efix,k_to_e;

    const char REVISION[]="$Revision::      $ ($Date::                                              $)";
    if(nrhs==0&&nlhs==1){
            plhs[0]=mxCreateString(REVISION); 
            return;
    }
      

      if(nrhs<NUM_IN_args-1){
          std::stringstream buf;
          buf<<" this function takes "<<NUM_IN_args<<" input parameters, namely ";
          buf<< "transf_matrix, data, detector_coordinates and four or three system variables";
          mexErrMsgTxt(buf.str().c_str());
      }
      if(nlhs!=1){
          mexErrMsgTxt("this function takes one output argument");
      }
      for(i=0;i<(unsigned int)nrhs;i++){
          if(!prhs[i]){
              std::stringstream buf;
              buf<<" parameter N "<<i<<" can not be empty";
              mexErrMsgTxt(buf.str().c_str());
          }
      }
      if(!mxIsStruct(prhs[Data])){
          mexErrMsgTxt("second argument (Data) has to be a single structure ");
      }
      if(!mxIsStruct(prhs[Detectors])){
          mexErrMsgTxt("third argument (Detectors) has to be a single structure");
      }




     double *pProj_matrix = (double *)mxGetPr(prhs[Spec_to_proj]);
     double *pEnergy      = (double *)mxGetPr(mxGetField(prhs[Data],0,"en"));
     double *pDetPhi      = (double *)mxGetPr(mxGetField(prhs[Detectors],0,"phi"));
     double *pDetPsi      = (double *)mxGetPr(mxGetField(prhs[Detectors],0,"azim"));

     efix   = getMatlabScalar(prhs[nEfix],"variable efix");
     k_to_e = getMatlabScalar(prhs[nK_to_e],"variable k_to_e");
     eMode  = (int)getMatlabScalar(prhs[nEmode],"variable eMode");
     if(eMode!=1){
        mexErrMsgTxt("no modes except mode 1 are currently supported");
     }
     if(nrhs==NUM_IN_args-1){   // the n-threads is not specified; using default (1)
         nThreads=1;
     }else{
         nThreads=(int)getMatlabScalar(prhs[nNThreads],"variable nThreads");
     }

   if(mxGetM(prhs[Spec_to_proj])!=3||mxGetN(prhs[Spec_to_proj])!=3){
          mexErrMsgTxt("first argument (projection matix) has to be 3x3 matrix");
    }
    if(pEnergy==NULL){
          mexErrMsgTxt("experimental data can not be empty");
    }
    nDataPoints =mxGetN(mxGetField(prhs[Data],0,"S"));
    nEnShed     =mxGetM(mxGetField(prhs[Data],0,"S"));
    nDetectors  =mxGetN(mxGetField(prhs[Detectors],0,"phi"));
    nEnergies   =mxGetM(mxGetField(prhs[Data],0,"en"));
    if(nDataPoints !=nDetectors){
            mexErrMsgTxt("spectrum data are not consistent with the detectors data");
    }

    mwSize dims[2],nEnPoints;
    double *pEnPoints;
    if(nEnergies==nEnShed){     // energy is calculated on edges of energy bins
           nEnPoints=nEnergies;
           pEnPoints    = (double *)mxCalloc(nEnPoints, sizeof(double));
           if(!pEnPoints){				mexErrMsgTxt("error allocating memory for auxiliary energy points");
           }
           for(i=0;i<nEnPoints;i++){
                pEnPoints[i] = pEnergy[i];
            }

    }else if(nEnShed+1==nEnergies){ // energy is calculated in centres of energy bins
           nEnPoints=nEnergies-1;
           pEnPoints    = (double *)mxCalloc(nEnPoints, sizeof(double));
           if(!pEnPoints){				mexErrMsgTxt("error allocating memory for auxiliary energy points");
           }
            for(i=0;i<nEnPoints;i++){
                pEnPoints[i] = 0.5*(pEnergy[i]+pEnergy[i+1]);
            }



    }else{
        mexErrMsgTxt("Energies in data spectrum and in energy spectrum are not consistent");
    }


    dims[0]=4;
    dims[1]=nDetectors*nEnPoints;
    plhs[0]= mxCreateNumericArray(2,dims, mxDOUBLE_CLASS,mxREAL);
    if(!plhs[0]){
        mexErrMsgTxt("Can not allocate memory for output data");
    }
    double *pTransfDet = (double *)mxGetPr(plhs[0]);
    try{
        calc_projections_emode1(pTransfDet,pProj_matrix,pEnPoints,nEnPoints,pDetPhi,pDetPsi,nDetectors,efix,k_to_e,nThreads);
        mxFree(pEnPoints);
    }catch(char const *err){
        mxFree(pEnPoints);
        mexErrMsgTxt(err);
    }


}
const double 	Pi = 3.1415926535897932384626433832795028841968;
const double    grad2rad=Pi/180;

void calc_projections_emode1(double * const pTransfDetectors,
                             double const * const pMatrix,double const * const pEnergies, mwSize nEnergies,
                             double const * const pDetPhi,double const * const pDetPsi, mwSize nDetectors,
                             double efix, double k_to_e,int nThreads){
/********************************************************************************************************************
* Calculate projections in direct mode;
* Output:
* pTransfDetectors[4*nDetectors*nEnergies] the matrix of 4D coordinates detectors. The coordinates are transformed  into the projections axis
* Inputs:
* pMatrix[3,3]          Matrix to convert components from the spectrometer frame to projection axes
* pEnergies[nEnergies]  Array of energies of arrival of detected particles
* pDetPhi[nDetectors]   ! -- arrays of  ... and
* pDetPsi[nDetectors]   ! -- azimutal coordinates of the detectors
* efix      -- initial energy of the particles
* k_to_e    -- De-Broyle parameter to transform energy of particles into their wavelength
* enRange   -- how to treat energy array -- relate energies to the bin center or to the bin edges
* nThreads  -- number of computational threads to start in parallel mode
*/


    mwSize i;
    double ki,*pKf;
    ki=sqrt(efix/k_to_e);
//    kf=sqrt((efix-eps)/k_to_e); % [nEnergies x 1]

    pKf= (double *)mxCalloc(nEnergies, sizeof(double));
    if(!pKf){  throw(" Can not allocate temporary memory for array of wave vectors");}
    for(i=0;i<nEnergies;i++){
            pKf[i]=sqrt((efix-pEnergies[i])/k_to_e);
    }

    double phi,psi,sPhi,ex,ey,ez,q1,q2,q3;
    mwSize i0,j0,j;
    int ii;

    omp_set_num_threads(nThreads);
#pragma omp parallel default(none), private(ii,j,i0,j0,ex,ey,ez,phi,psi,sPhi,q1,q2,q3), \
     shared(nEnergies,nDetectors,pKf),\
     firstprivate(ki)
    {
#pragma omp for
    for(ii=0;ii<nDetectors;ii++){
//	detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
        phi =pDetPhi[ii]*grad2rad;
        psi =pDetPsi[ii]*grad2rad;
        sPhi=sin(phi);
        ex = cos(phi);
        ey = sPhi*cos(psi);
        ez = sPhi*sin(psi);

//    q(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
//        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
        i0 = ii*nEnergies;
        for(j=0;j<nEnergies;j++){
            j0=4*(i0+j);
            q1    = ki - ex*pKf[j];
            q2    = -ey*pKf[j];
            q3    = -ez*pKf[j];

//			u(1,i)=c(1,1)*q(1,i)+c(1,2)*q(2,i)+c(1,3)*q(3,i)
//		    u(2,i)=c(2,1)*q(1,i)+c(2,2)*q(2,i)+c(2,3)*q(3,i)
//			u(3,i)=c(3,1)*q(1,i)+c(3,2)*q(2,i)+c(3,3)*q(3,i)
            pTransfDetectors[j0  ] = pMatrix[0]*q1+pMatrix[3]*q2+pMatrix[6]*q3;
            pTransfDetectors[j0+1] = pMatrix[1]*q1+pMatrix[4]*q2+pMatrix[7]*q3;
            pTransfDetectors[j0+2] = pMatrix[2]*q1+pMatrix[5]*q2+pMatrix[8]*q3;


//			q(4,:)=repmat(eps',1,ndet);
            pTransfDetectors[j0+3] = pEnergies[j];
        }
    }
    }  // end parallel

    mxFree(pKf);
}

/*
      case(1)
    ki=sqrt(efix/k_to_e);
    kf=sqrt((efix-eps)/k_to_e); % [ne x 1]

    detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    qspec(4,:)=repmat(eps',1,ndet);
case(2)
    kf=sqrt(efix/k_to_e);
    ki=sqrt((efix+eps)/k_to_e); % [ne x 1]

    detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat([ki';zeros(1,ne);zeros(1,ne)],[1,ndet]) - ...
        repmat(kf,[3,ne*ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
    qspec(4,:)=repmat(eps',1,ndet);
case(3)
    k=(2*pi)./lambda;   % [ne x 1]

    Q_by_k = repmat([1;0;0],[1,ndet]) - [cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
    qspec(1:3,:) = repmat(k',[3,ndet]).*reshape(repmat(reshape(Q_by_k,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);



*/
