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
#include <map>

 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */
 /*------------------------------------------------------------------------ */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision:: 1612 $ ($Date:: 2018-06-14 14:37:41 +0100 (Thu, 14 Jun 2018) $)";
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

    // decide what size the output would have
    std::vector<mwSize> rez_dim_sizes;
    bool expandA(false), expandB(false);
    size_t nDims, Mk;
    calc_output_size(dimsA, ndimsA, dimsB, ndimsB, rez_dim_sizes, nDims, Mk, expandA, expandB);
    size_t Mi = rez_dim_sizes[0];
    size_t Mj = rez_dim_sizes[1];
    size_t Mk0 = dimsB[0];


    /*-----------------------------------------------------------------------------
     * Check for proper input type and call the appropriate multiply routine.
     * To be similar to MATLAB for mixed single-double operations, convert
     * single inputs to double, do the calc, then convert back to single.
     *----------------------------------------------------------------------------- */


    auto operation = get_op_type(a_mat, b_mat);
    MatrixTypes op_type     = operation.first;
    mxClassID   result_type = operation.second;

    switch (op_type) {
    case(MatrixTypes::double_double): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], result_type, mxComplexity(0));
        double *pRez = mxGetPr(rez);
        double const *const pA(mxGetPr(a_mat));
        double const *const pB(mxGetPr(b_mat));
        mat_multiply<double, double, double>(pRez, pA, pB, Mi, Mj, Mk0, Mk, expandA, expandB, n_threads);
        plhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::double_single): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], result_type, mxComplexity(0));
        double *pRez = mxGetPr(rez);
        double const *const pA(mxGetPr(a_mat));
        float const *const pB = reinterpret_cast<float *>(mxGetData(b_mat));
        mat_multiply<double, double, float>(pRez, pA, pB, Mi, Mj, Mk0, Mk, expandA, expandB, n_threads);
        plhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::single_double): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], result_type, mxComplexity(0));
        double *pRez = mxGetPr(rez);
        float const *const pA = reinterpret_cast<float *>(mxGetData(a_mat));
        double const *const pB(mxGetPr(b_mat));
        mat_multiply<double, float, double>(pRez, pA, pB, Mi, Mj, Mk0, Mk, expandA, expandB, n_threads);
        plhs[0] = rez;
    }
                                      break;
    case(MatrixTypes::single_single): {
        mxArray * rez = mxCreateNumericArray(nDims, &rez_dim_sizes[0], result_type, mxComplexity(0));
        float *pRez = reinterpret_cast<float *>(mxGetData(rez));
        float const *const pA = reinterpret_cast<float *>(mxGetData(a_mat));
        float const *const pB = reinterpret_cast<float *>(mxGetData(b_mat));
        mat_multiply<float, float, float>(pRez, pA, pB, Mi, Mj, Mk0, Mk, expandA, expandB, n_threads);
        plhs[0] = rez;
    }
                                      break;
    default:
        mexErrMsgTxt("Unsupported combination of input multiplier's types. Ask developers to add this type");

    }


    return;

}

/* The map of containing the types of operations which are currently supported */
const std::map<size_t, operations> supported_op_map = {
 { size_t(mxDOUBLE_CLASS)*size_t(mxOBJECT_CLASS) + size_t(mxDOUBLE_CLASS) , operations(double_double,mxDOUBLE_CLASS) },
 { size_t(mxDOUBLE_CLASS)*size_t(mxOBJECT_CLASS) + size_t(mxSINGLE_CLASS) ,operations(double_single,mxDOUBLE_CLASS) },
 { size_t(mxSINGLE_CLASS)*size_t(mxOBJECT_CLASS) + size_t(mxDOUBLE_CLASS) ,operations(single_double,mxDOUBLE_CLASS) },
 { size_t(mxSINGLE_CLASS)*size_t(mxOBJECT_CLASS) + size_t(mxSINGLE_CLASS) ,operations(single_single,mxSINGLE_CLASS) }
};


/* function defines the type of matrix multiplication and type of the multiplication result
    as the function of types of input matrices */
operations  get_op_type(mxArray const *const mat_a, mxArray const *const mat_b) {

    mxClassID category_a = mxGetClassID(mat_a);
    mxClassID category_b = mxGetClassID(mat_b);

    size_t op_type_key = size_t(category_a)*size_t(mxOBJECT_CLASS) + size_t(category_b);
    auto opIt = supported_op_map.find(op_type_key);
    if (opIt == supported_op_map.end()) {
        mexErrMsgTxt("Unsupported combination of input multiplier's types. Ask developers to add this type");
    }
    operations operation = opIt->second;

    return operation;

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
    std::vector<mwSize> & rez_dim_sizes, size_t &nDims, size_t &Mk, bool & expandA, bool &expandB) {

    size_t MkA = calc_mdims(dimsA, ndimsA);
    size_t MkB = calc_mdims(dimsB, ndimsB);

    if (MkA != MkB) {
        if (MkA == 1 || MkB == 1) {
            if (MkA == 1) {
                expandA = true;
                Mk = MkB;
                nDims = ndimsB;
            }
            else {
                expandB = true;
                Mk = MkA;
                nDims = ndimsA;
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
        nDims = ndimsA;
    }
    rez_dim_sizes.resize(nDims);
    rez_dim_sizes[0] = dimsA[0];
    rez_dim_sizes[1] = dimsB[1];
    if (expandB) {
        for (size_t i = 2; i < nDims; i++) {
            rez_dim_sizes[i] = dimsA[i];
        }
    }
    else {
        for (size_t i = 2; i < nDims; i++) {
            rez_dim_sizes[i] = dimsB[i];
        }
    }


}
