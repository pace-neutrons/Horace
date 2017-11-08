/*************************************************************************************
 * Highly simplified and reduced mtimesx routine, used to multiply matrices, used in Tobyfit
 *
 * The usage is as follows (arguments in brackets [] are optional):
 *
 * Syntax
 *
  * C = mtimesx(A ,B [,n_omp_threads])
 *
 * Description
 *
 * mtimesx performs the matrix calculation C = A * B, where:
 *    A = A single or double or integer scalar, matrix, or array.
 *    B = A single or double or integer scalar, matrix, or array.
 *
 *  M = mtimesx returns a string with the current calculation mode. The string
 *      will  be 'SPEEDOMP'.
 *
 *  M = mtimesx(mode) sets the calculation mode to mode. The mode variable
 *      must be either the string 'MATLAB' or the string 'SPEED'. The return
 *      variable M is the previous mode setting prior to setting the new mode.
 *      The mode is case insensitive (lower or upper case is OK). You can also
 *      set one of the OMP modes if you have compiled with an OpenMP compiler.
 *
 *
 * Examples:
 *
 *  C = mtimesx(A,B)         % performs the calculation C = A * B

 *
 * mtimesx supports nD inputs. For these cases, the first two dimensions specify the
 * matrix multiply involved. The remaining dimensions are duplicated and specify the
 * number of individual matrix multiplies to perform for the result. i.e., mtimesx
 * treats these cases as arrays of 2D matrices and performs the operation on the
 * associated parings. For example:
 *
 *     If A is (2,3,4,5) and B is (3,6,4,5), then
 *     mtimesx(A,B) would result in C(2,6,4,5)
 *     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,i,j), i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(2,6,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = A(:,:,m,n) * B(:,:,m,n);
 *         end
 *     end
 *
 * The first two dimensions must conform using the standard matrix multiply rules
 * taking the transa and transb pre-operations into account, and dimensions 3:end
 * must match exactly or be singleton (equal to 1). If a dimension is singleton
 * then it is virtually expanded to the required size (i.e., equivalent to a
 * repmat operation to get it to a conforming size but without the actual data
 * copy). For example:
 *
 *     If A is (2,3,4,5) and B is (3,6,1,5), then
 *     mtimesx(A,B) would result in C(2,6,4,5)
 *     where C(:,:,i,j) = A(:,:,i,j) * B(:,:,1,j), i=1:4, j=1:5
 *
 *     which would be equivalent to the MATLAB m-code:
 *     C = zeros(2,6,4,5);
 *     for m=1:4
 *         for n=1:5
 *             C(:,:,m,n) = A(:,:,m,n) * B(:,:,1,n);
 *         end
 *     end
 *
 ****************************************************************************/
 /*
 *
 */
#include "MatMultiply.h"
#include <string>

 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    /*-------------------------------------------------------------------------
     * Check for proper number of inputs and outputs
     *------------------------------------------------------------------------- */

    if (nlhs > 1) {
        mexErrMsgTxt("Must have at most 1 output.");
    }

    /*-------------------------------------------------------------------------
     * Compatibility with mtimesx: If no inputs, just return the current (and the only existing) mode
     *------------------------------------------------------------------------- */
    if (nrhs == 0) {
        plhs[0] = mxCreateString("LOOPSOMP");
        return;
    }

    /*-------------------------------------------------------------------------
     * Find out if any input is unsupported directive
     *------------------------------------------------------------------------- */
    for (int i = 0; i < nrhs; i++) {
        if (mxIsChar(prhs[i])) {
            mexErrMsgTxt("Modes of operation are not supported by mtimexs_horace. Use original mtimesx function if you need them");
        }
        if (mxIsComplex(prhs[i])) {
            mexErrMsgTxt("Complex arrays multiplication is not yet supported by mtimexs_horace. Use original mtimesx function if you need them");
        }
        if (mxIsSparse(prhs[i])) {
            mexErrMsgTxt("Sparse arrays multiplication is not yet supported by mtimexs_horace. Use Matlab");
        }
    }
    int n_threads(1);
    if (nrhs > 2) {
        n_threads = static_cast<int>(mxGetScalar(prhs[2]));
    }

    mxArray const *const a_mat(prhs[0]);
    mxArray const *const b_mat(prhs[1]);

    mwSize ndimsA = mxGetNumberOfDimensions(a_mat);
    mwSize ndimsB = mxGetNumberOfDimensions(b_mat);
    const mwSize * dimsA = mxGetDimensions(a_mat);
    const mwSize * dimsB = mxGetDimensions(b_mat);
    if (dimsA[1] != dimsB[0]) {
        std::string ERR = "Size of the second dimension of first multiplier ("
            + std::to_string(dimsA[1])
            + ") has to be equal to the size of the first dimension of the second multiplier ("
            + std::to_string(dimsA[1])
            + ")";
        mexErrMsgTxt(ERR.c_str());
    }

    size_t Mi = dimsA[0];
    size_t Mj = dimsA[1];

    // decide what size the output would have
    std::vector<size_t> rez_dim_sizes;
    bool expandA(false), expandB(false);
    size_t nDims, Mk;
    calc_output_size(dimsA, ndimsA, dimsB, ndimsB, rez_dim_sizes, nDims, Mk, expandA, expandB);

    /*-----------------------------------------------------------------------------
     * Check for proper input type and call the appropriate multiply routine.
     * To be similar to MATLAB for mixed single-double operations, convert
     * single inputs to double, do the calc, then convert back to single.
     *----------------------------------------------------------------------------- */


    auto op_type = get_op_type(a_mat, b_mat);

    switch (std::get<0>(op_type)) {
    case(MatrixTypes::double_double): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], std::get<1>(op_type), mxComplexity(0));
        double *pRez = mxGetPr(rez);
        double const *const pA(mxGetPr(a_mat));
        double const *const pB(mxGetPr(b_mat));
        mat_multiply<double, double, double>(pRez, pA, pB, Mi, Mj, Mk, expandA, expandB, n_threads);
        prhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::double_single): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], std::get<1>(op_type), mxComplexity(0));
        double *pRez = mxGetPr(rez);
        double const *const pA(mxGetPr(a_mat));
        float const *const pB = reinterpret_cast<float *>(mxGetData(b_mat));
        mat_multiply<double, double, float>(pRez, pA, pB, Mi, Mj, Mk, expandA, expandB, n_threads);
        prhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::single_double): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], std::get<1>(op_type), mxComplexity(0));
        double *pRez = mxGetPr(rez);
        float const *const pA = reinterpret_cast<float *>(mxGetData(a_mat));
        double const *const pB(mxGetPr(b_mat));
        mat_multiply<double, float, double>(pRez, pA, pB, Mi, Mj, Mk, expandA, expandB, n_threads);
        prhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::single_single): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], std::get<1>(op_type), mxComplexity(0));
        float *pRez = reinterpret_cast<float *>(mxGetData(rez));
        float const *const pA = reinterpret_cast<float *>(mxGetData(a_mat));
        float const *const pB = reinterpret_cast<float *>(mxGetData(b_mat));
        mat_multiply<float, float, float>(pRez, pA, pB, Mi, Mj, Mk, expandA, expandB, n_threads);
        prhs[0] = rez;
    }
                                      break;
    default:
        mexErrMsgTxt("Unsupported types of multipliers");

    }


    return;

}
/* function defines the type of matrix multiplication as the function of types of input matrix */
std::tuple<MatrixTypes, mxClassID>  get_op_type(mxArray const *const mat_a, mxArray const *const mat_b) {

    mxClassID category_a = mxGetClassID(mat_a);
    mxClassID category_b = mxGetClassID(mat_b);


    /*
        switch (category) {
        case mxINT8_CLASS:   analyze_int8(numeric_array_ptr);   break;
        case mxUINT8_CLASS:  analyze_uint8(numeric_array_ptr);  break;
        case mxINT16_CLASS:  analyze_int16(numeric_array_ptr);  break;
        case mxUINT16_CLASS: analyze_uint16(numeric_array_ptr); break;
        case mxINT32_CLASS:  analyze_int32(numeric_array_ptr);  break;
        case mxUINT32_CLASS: analyze_uint32(numeric_array_ptr); break;
        case mxINT64_CLASS:  analyze_int64(numeric_array_ptr);  break;
        case mxUINT64_CLASS: analyze_uint64(numeric_array_ptr); break;
        case mxSINGLE_CLASS: analyze_single(numeric_array_ptr); break;
        case mxDOUBLE_CLASS: analyze_double(numeric_array_ptr); break;
        default: break;
        }

        */
    return std::make_tuple<MatrixTypes, mxClassID>(double_double, mxDOUBLE_CLASS);

}

/* calculate the capacity of higher dimensions of an nD>2 array
* Inputs:
* dims_array -- pointer to array containing dimensions of multidimensional array
* ndims_in_array -- number of dimensions in this array
* Returns:
* total number of elements in higher dimensions of nD array e.g.
* if array size is 3x2x4x5 returns 4x5=20
*/
size_t calc_mdims(mwSize const *const dims_array, size_t ndims_in_array) {

    size_t capac(1);
    if (ndims_in_array > 2) {
        for (size_t i = 2; i < ndims_in_array; ++i) {
            capac *= dims_array[i];
        }
    }
    return capac;

}

void calc_output_size(mwSize const *const dimsA, size_t ndimsA, mwSize const *const  dimsB, size_t ndimsB,
    std::vector<size_t> & rez_dim_sizes, size_t &nDims, size_t &Mk, bool & expandA, bool &expandB) {

    size_t MkA = calc_mdims(dimsA, ndimsA);
    size_t MkB = calc_mdims(dimsB, ndimsB);

    if (MkA != MkB) {
        if (MkA == 1 || MkB == 1) {
            if (MkA != 1) {
                expandA = true;
                Mk = MkB;
            }
            else {
                expandB = true;
                Mk = MkA;
            }
        }
        else {
            std::string ERR = "The capacity of higher then 2 dimensions of both multipliers have to be either equal or one of them has to be 1. "
                "in fact, the top size of the first multiplier is "
                + std::to_string(MkA)
                + " and size of the second multiplier is "
                + std::to_string(MkB);
            mexErrMsgTxt(ERR.c_str());
        }
    } // All arrays have the same sizes
    else {
        Mk = MkA;

    }
    nDims = Mk + 2;
    rez_dim_sizes.resize(nDims);
    rez_dim_sizes[0] = dimsA[0];
    rez_dim_sizes[1] = dimsB[1];
    if (expandB) {
        for (size_t i = 2; i < MkA; i++) {
            rez_dim_sizes[i] = dimsA[i];
        }
    }
    else {
        for (size_t i = 2; i < MkB; i++) {
            rez_dim_sizes[i] = dimsB[i];
        }
    }


}
