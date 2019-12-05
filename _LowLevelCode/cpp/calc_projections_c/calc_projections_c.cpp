// calc_projections_c.cpp : Defines the exported functions for the DLL application.
//
#include "calc_projections_c.h"
//
// enumerate input parameters for easy references. 
enum inPar {
    Spec_to_proj,
    Data,
    Detectors,
    nEfix,
    nK_to_e,
    nEmode,
    nNThreads,
    uRangeMode, // if provided, specifies the format of pixel output. (see urangeModes in header for details)
    NUM_IN_args
};


//============================================================================================
//**
//> the function transforms the detector positions from the instrumental to the crystal system of coordinates
//
// usage:
// ucoordinates=calc_projections_c(transf_matrix,data,detectors);
//
// input parameters:
// transf_matrix -- 3x3 rotational(Sp=1) matrix of transformation from device coordinates to the
//                   crystal coordinated
// data          -- structure with the data from experiment, has to have fields in accordance with the
//                  enum dataStructure above; The program uses the field data.energy --an array of 1xnEnergy values
//
// detectors     -- structure with the data, which describes the detector positions with the field,
//                  accordingly to enum detectorsStructure
//                  the program uses the fields phi and psi which should be a 1xnDetectors arrays
// efix          -- Fixed energy (meV)
// k_to_e        -- constant to transform the neutron wave-vector into the incident neutron energy
// emode         -- Direct geometry=1, indirect geometry=2, elastic=0
// nThreads      -- number of threads to use to run the program.
//
// Outputs:
// ucoordinates  -- 4xn_data*nEnergies vector of the signal and energies in the transformed coordinates
//<
//============================================================================================

//* Possible prototype for a generic function
double getMatlabScalar(const mxArray *pPar, const char * const fieldName) {
    if (pPar == NULL) {
        mexErrMsgTxt(" The parameter has to be defined");
    }
    if (mxGetM(pPar) != 1 || mxGetN(pPar) != 1) {
        std::stringstream buf;
        buf << *fieldName << " has to be a scalar\n";
        mexErrMsgTxt(buf.str().c_str());
    }
    return (double)*mxGetPr(pPar);
};
void getMatlabVector(const mxArray *pPar, double *&pValue, size_t &NComponents, const char * const fieldName) {
    if (pPar == NULL) {
        std::stringstream buf;
        buf << "The parameter: " << *fieldName << " has to be defined\n";
        mexErrMsgTxt(buf.str().c_str());
    }
    auto NRows = mxGetM(pPar);
    auto NCols = mxGetN(pPar);
    if (!(NRows == 1 || NCols == 1)) {
        std::stringstream buf;
        buf << "The variable " << *fieldName << " should be 1-dimensional array\n";
        mexErrMsgTxt(buf.str().c_str());
    }
    NComponents = size_t(NRows*NCols);
    pValue = mxGetPr(pPar);
};



//
//============================================================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    unsigned int nThreads(1), i;
    size_t nDataPoints(0), nEnShed(0), nEfixed(0);
    mwSize nDetectors, nEnergies;
    double *pEfix(nullptr), k_to_e;
    urangeModes uRange_mode;

    const char REVISION[] = "$Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }


    if (nrhs < NUM_IN_args - 1) {
        if (nrhs == NUM_IN_args - 2) { // uRangeMode is not specified; default urange mode, return pixel information
            uRange_mode = urangePixels;
        }
        else {
            std::stringstream buf;
            buf << " this function takes " << NUM_IN_args << " input parameters, namely ";
            buf << "transf_matrix, data, detector_coordinates and four or three system variables";
            mexErrMsgTxt(buf.str().c_str());
        }
    }
    bool forceNoUrange(false);
    if (nlhs != 2) {
        if (nlhs == 1) {
            uRange_mode = noUrange;
            forceNoUrange = true; // no urange is forced if no place for output array is provided. No point of allocating it then.
        }
        else {
            mexErrMsgTxt("this function takes two output arguments ");
        }
    }

    for (i = 0; i < (unsigned int)nrhs; i++) {
        if (!prhs[i]) {
            std::stringstream buf;
            buf << " parameter N " << i << " can not be empty";
            mexErrMsgTxt(buf.str().c_str());
        }
    }
    if (!mxIsStruct(prhs[Data])) {
        mexErrMsgTxt("second argument (Data) has to be a single structure ");
    }
    if (!mxIsStruct(prhs[Detectors])) {
        mexErrMsgTxt("third argument (Detectors) has to be a single structure");
    }


    double *pProj_matrix = (double *)mxGetPr(prhs[Spec_to_proj]);
    double *pEnergy = (double *)mxGetPr(mxGetField(prhs[Data], 0, "en"));
    double *pDetPhi = (double *)mxGetPr(mxGetField(prhs[Detectors], 0, "phi"));
    double *pDetPsi = (double *)mxGetPr(mxGetField(prhs[Detectors], 0, "azim"));


    getMatlabVector(prhs[nEfix], pEfix, nEfixed, "efix");
    k_to_e = getMatlabScalar(prhs[nK_to_e], "variable k_to_e");
    int ieMode = (int)getMatlabScalar(prhs[nEmode], "variable eMode");
    if (ieMode < 0 || ieMode > 2) {
        mexErrMsgTxt("only modes 0-2 (Elastic,Direct,Indirect) are currently supported");
    }
    eMode mode = eMode(ieMode);

    if (nrhs == NUM_IN_args - 1) {   // the n-threads is not specified; using default (1)
        nThreads = 1;
    }
    else {
        nThreads = (int)getMatlabScalar(prhs[nNThreads], "variable nThreads");
    }
    if (nThreads < 1)nThreads = 1;
    if (nThreads > 64)nThreads = 64;
    //
    if (nrhs == NUM_IN_args) {
        int iMode = (int)getMatlabScalar(prhs[uRangeMode], "variable proj_mode");
        if (iMode > -1 && iMode < 3) {
            uRange_mode = static_cast<urangeModes>(iMode);
        }
        else {
            uRange_mode = urangePixels;
        }
        if (forceNoUrange)uRange_mode = noUrange;
    }

    if (mxGetM(prhs[Spec_to_proj]) != 3 || mxGetN(prhs[Spec_to_proj]) != 3) {
        mexErrMsgTxt("first argument (projection matrix) has to be 3x3 matrix");
    }
    if (pEnergy == NULL) {
        mexErrMsgTxt("experimental data can not be empty");
    }

    mxArray *maSignal = mxGetField(prhs[Data], 0, "S");
    if (maSignal == NULL) {
        mexErrMsgTxt("Can not retrieve signal (S field) array from the data structure");
    }
    double * pSignal = (double *)mxGetPr(maSignal);
    double * pError = (double *)mxGetPr(mxGetField(prhs[Data], 0, "ERR"));
    if (pError == NULL) {
        mexErrMsgTxt("Can not retrieve error (ERR field) array from the data structure");
    }

    nDataPoints = mxGetN(maSignal);
    nEnShed = mxGetM(maSignal);

    nDetectors = mxGetN(mxGetField(prhs[Detectors], 0, "phi"));
    nEnergies = mxGetM(mxGetField(prhs[Data], 0, "en"));

    if (nDataPoints != nDetectors) {
        mexErrMsgTxt("spectrum data are not consistent with the detectors data");
    }
    if (!(nEfixed == nDetectors || nEfixed == 1)) {
        mexErrMsgTxt("Efixed should be either single value or vector of nDetector's length");
    }

    mxArray *mapDet = mxGetField(prhs[Detectors], 0, "group");
    double * pDetGroup;
    bool clearTmpDet(false);
    if (mapDet == NULL)
    {
        pDetGroup = new double[nDetectors];
        clearTmpDet = true;
        for (size_t i = 0; i < nDetectors; i++)pDetGroup[i] = double(i) + 1;
    }
    else
    {
        pDetGroup = (double *)mxGetPr(mapDet);
    }



    mwSize dims[2], nEnPoints;
    double *pEnPoints;
    if (nEnergies == nEnShed) {     // energy is calculated on edges of energy bins
        nEnPoints = nEnergies;
        pEnPoints = (double *)mxCalloc(nEnPoints, sizeof(double));
        if (!pEnPoints) {
            if (clearTmpDet) delete[] pDetGroup;
            mexErrMsgTxt("error allocating memory for auxiliary energy points");
        }

        for (i = 0; i < nEnPoints; i++) {
            pEnPoints[i] = pEnergy[i];
        }

    }
    else if (nEnShed + 1 == nEnergies) { // energy is calculated in centers of energy bins
        nEnPoints = nEnergies - 1;
        pEnPoints = (double *)mxCalloc(nEnPoints, sizeof(double));

        if (!pEnPoints)
        {
            if (clearTmpDet) delete[] pDetGroup;
            mexErrMsgTxt("error allocating memory for auxiliary energy points");
        }

        for (i = 0; i < nEnPoints; i++) {
            pEnPoints[i] = 0.5*(pEnergy[i] + pEnergy[i + 1]);
        }

    }
    else {
        if (clearTmpDet) delete[] pDetGroup;
        mexErrMsgTxt("Energies in data spectrum and in energy spectrum are not consistent");
    }
    dims[0] = 2;
    dims[1] = 4;
    plhs[0] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    if (!plhs[0]) {
        if (clearTmpDet) delete[] pDetGroup;

        mexErrMsgTxt("Can not allocate memory for output data");
    }

    // Allocate output array of pixels if requested by urangeMode
    switch (uRange_mode)
    {
    case noUrange:
    {
        if (!forceNoUrange)
        {
            dims[0] = 9;
            dims[1] = 0;
            plhs[1] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
        }
        break;
    }
    case urangeCoord:
    {
        dims[0] = 4;
        dims[1] = nDetectors * nEnPoints;
        plhs[1] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
        break;
    }
    case urangePixels:
    {
        dims[0] = 9;
        dims[1] = nDetectors * nEnPoints;
        plhs[1] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);

    }
    default:
        break;
    }
    //
    if (!plhs[1] && !forceNoUrange) {
        if (clearTmpDet) delete[] pDetGroup;
        mexErrMsgTxt("Can not allocate memory for output pixels data");
    }

    //
    double *pMinMax = (double *)mxGetPr(plhs[0]);
    double *pTransfDet = (double *)mxGetPr(plhs[1]);
    try {
        calc_projections_emode(pMinMax, pTransfDet, mode, uRange_mode, pSignal, pError, pDetGroup,
            pProj_matrix, pEnPoints, nEnPoints, pDetPhi, pDetPsi, nDetectors, pEfix, nEfixed, k_to_e, nThreads);
        mxFree(pEnPoints);
    }
    catch (char const *err) {
        mxFree(pEnPoints);
        if (clearTmpDet) delete[] pDetGroup;
        mexErrMsgTxt(err);
    }

    if (clearTmpDet) delete[] pDetGroup;


}
const double    Pi = 3.1415926535897932384626433832795028841968;
const double    grad2rad = Pi / 180;

void calc_projections_emode(double * const pMinMax,
    double * const pTransfDetectors,
    eMode emode, urangeModes urange_mode,
    double const * const pSignal, double const * const pError, double const * const pDetGroup,
    double const * const pMatrix, double const * const pEnergies, mwSize nEnergies,
    double const * const pDetPhi, double const * const pDetPsi, mwSize nDetectors,
    double const * const pEfix, size_t nEfixed, double k_to_e, int nThreads)
{
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


    double ki, *pKf(nullptr);
    bool singleEfixed(true);
    if (nEfixed == 1) {
        double efix = *pEfix;
        ki = sqrt(efix / k_to_e);
        //    kf=sqrt((efix-eps)/k_to_e); % [nEnergies x 1]

        pKf = (double *)mxCalloc(nEnergies, sizeof(double));
        if (!pKf) { throw(" Can not allocate temporary memory for array of wave vectors"); }
        // 
        for (mwSize i = 0; i < nEnergies; i++)
        {
            switch (emode)
            {
            case Direct:
            {
                pKf[i] = sqrt((efix - pEnergies[i]) / k_to_e);
                break;
            }
            case Indirect:
            {
                pKf[i] = sqrt((efix + pEnergies[i]) / k_to_e);
                break;
            }
            case Elastic:
            {
                // in this case, energies array should contain wavelength
                pKf[i] = 2 * Pi / (pEnergies[i]);
                break;
            }
            }
        }
    }
    else {
        singleEfixed = false;
    }

    omp_set_num_threads(nThreads);

    std::vector<double> qe_min(4 * nThreads, FLT_MAX);
    std::vector<double> qe_max(4 * nThreads, -FLT_MAX);
#pragma omp parallel default(none)  \
    shared(pKf,qe_min,qe_max) \
    firstprivate(nDetectors,nEnergies,ki,urange_mode,emode,singleEfixed,pEfix,pEnergies,k_to_e) //\
    //reduction(min: q1_min,q2_min,q3_min,e_min; max: q1_max,q2_max,q3_max,e_max)
    {
#pragma omp for 
        for (long ii = 0; ii < nDetectors; ii++)
        {
            //	detdcn=[cosd(det.phi); sind(det.phi).*cosd(det.azim); sind(det.phi).*sind(det.azim)];   % [3 x ndet]
            double phi = pDetPhi[ii] * grad2rad;
            double psi = pDetPsi[ii] * grad2rad;
            double sPhi = sin(phi);
            double ex = cos(phi);
            double ey = sPhi * cos(psi);
            double ez = sPhi * sin(psi);
            double k_f;
            if (singleEfixed)
                k_f = ki; // Used in indirect mode only
            else
                k_f = sqrt(pEfix[ii] / k_to_e);

            //    q(1:3,:) = repmat([ki;0;0],[1,ne*ndet]) - ...
            //        repmat(kf',[3,ndet]).*reshape(repmat(reshape(detdcn,[3,1,ndet]),[1,ne,1]),[3,ne*ndet]);
            size_t i0 = ii * nEnergies;
            for (size_t j = 0; j < nEnergies; j++)
            {
                double q1, q2, q3, qe[4];
                switch (emode) {
                case Direct:
                {
                    q1 = ki - ex * pKf[j];
                    q2 = -ey * pKf[j];
                    q3 = -ez * pKf[j];
                    break;
                }
                case Indirect:
                {
                    if (singleEfixed)
                        q1 = pKf[j] - ex * k_f;
                    else {
                        double k_i = sqrt((pEfix[ii] + pEnergies[j]) / k_to_e);
                        q1 = k_i - ex * k_f;
                    }
                    q2 = -ey * k_f;
                    q3 = -ez * k_f;
                    break;

                }
                case Elastic:
                {
                    q1 = (1 - ex) * pKf[j];
                    q2 = -ey * pKf[j];
                    q3 = -ez * pKf[j];
                    break;
                }
                }

                //u(1,i)=c(1,1)*q(1,i)+c(1,2)*q(2,i)+c(1,3)*q(3,i)
                //u(2,i)=c(2,1)*q(1,i)+c(2,2)*q(2,i)+c(2,3)*q(3,i)
                //u(3,i)=c(3,1)*q(1,i)+c(3,2)*q(2,i)+c(3,3)*q(3,i)
                qe[0] = pMatrix[0] * q1 + pMatrix[3] * q2 + pMatrix[6] * q3;
                qe[1] = pMatrix[1] * q1 + pMatrix[4] * q2 + pMatrix[7] * q3;
                qe[2] = pMatrix[2] * q1 + pMatrix[5] * q2 + pMatrix[8] * q3;
                //q(4,:)=repmat(eps',1,ndet);
                qe[3] = pEnergies[j];
                switch (urange_mode)
                {
                case noUrange:
                {
                    int n_cur = 4 * omp_get_thread_num();
                    for (int ike = 0; ike < 4; ike++)
                    {
                        // min-max values;
                        if (qe[ike] < qe_min[n_cur + ike])qe_min[n_cur + ike] = qe[ike];
                        if (qe[ike] > qe_max[n_cur + ike])qe_max[n_cur + ike] = qe[ike];
                    }
                    break;
                }
                case urangeCoord:
                {
                    size_t j0 = 4 * (i0 + j);
                    int n_cur = 4 * omp_get_thread_num();
                    for (int ike = 0; ike < 4; ike++)
                    {
                        // min-max values;
                        if (qe[ike] < qe_min[n_cur + ike])qe_min[n_cur + ike] = qe[ike];
                        if (qe[ike] > qe_max[n_cur + ike])qe_max[n_cur + ike] = qe[ike];
                        pTransfDetectors[j0 + ike] = qe[ike];
                    }

                    break;
                }
                case urangePixels:
                {

                    size_t j0 = 9 * (i0 + j);
                    int n_cur = 4 * omp_get_thread_num();
                    for (int ike = 0; ike < 4; ike++)
                    {
                        // min-max values;
                        if (qe[ike] < qe_min[n_cur + ike])qe_min[n_cur + ike] = qe[ike];
                        if (qe[ike] > qe_max[n_cur + ike])qe_max[n_cur + ike] = qe[ike];
                        pTransfDetectors[j0 + ike] = qe[ike];
                    }

                    // to be consistent with MATLAB; should be ii+1 to be correct
                    pTransfDetectors[j0 + 4] = 1;
                    // pix(6,:)=reshape(repmat(det.group,[ne,1]),[1,ne*ndet]); % detector index
                    pTransfDetectors[j0 + 5] = pDetGroup[ii];
                    //pix(7,:)=reshape(repmat((1:ne)',[1,ndet]),[1,ne*ndet]); % energy bin index
                    pTransfDetectors[j0 + 6] = double(j) + 1;
                    //pix(8,:)=data.S(:)';
                    pTransfDetectors[j0 + 7] = pSignal[i0 + j];
                    //pix(9,:)=((data.ERR(:)).^2)';
                    pTransfDetectors[j0 + 8] = pError[i0 + j] * pError[i0 + j];
                }
                }


            }
        } // end omp for

    }  // end parallel block 
    if (pKf)mxFree(pKf);
    // mvs do not support reduction min/max Shame! Calculate single threaded here
    for (int i = 0; i < 4; i++) {
        pMinMax[2 * i + 0] = 1.e+38;
        pMinMax[2 * i + 1] = -1.e+38;
    }

    for (int ii = 0; ii < nThreads; ii++) {
        for (int ike = 0; ike < 4; ike++) {
            if (qe_min[4 * ii + ike] < pMinMax[2 * ike + 0])pMinMax[2 * ike + 0] = qe_min[4 * ii + ike];
            if (qe_max[4 * ii + ike] > pMinMax[2 * ike + 1])pMinMax[2 * ike + 1] = qe_max[4 * ii + ike];
        }
    }

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

