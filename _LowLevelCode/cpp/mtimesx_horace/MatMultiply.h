#pragma once
#include <include/CommonCode.h>
#include <utility/version.h>

enum MatrixTypes
{
    double_double,
    double_single,
    single_double,
    single_single,
    unsupported
};
/* function defines the type of matrix multiplication as the function of types of input matrix. See function definition for full parameters description*/
typedef std::pair<MatrixTypes, mxClassID> operations;
operations  get_op_type(mxArray const *const mat_a, mxArray const *const mat_b);

/* calculate the capacity of higher dimensions of an nD>2 array. See function definition for full parameters description*/
size_t calc_mdims(mwSize const *const dimsA, size_t ndimsA);

/* Calculate size and the dimensionality of the resulting array. See function definition for full parameters description */
void calc_output_size(mwSize const *const dimsA, size_t ndimsA, mwSize const *const  dimsB, size_t ndimsB,
    std::vector<mwSize> & rez_dim_sizes, size_t &nDims, size_t &Mk, bool & expandA, bool &expandB);


/* multiply two matrices or arrays of matrices 
* Parameters:
* ----------
* res     -- pointer to the contents of allocated MATLAB matrix which contains result
* a       -- pointer to the contents of the first MATLAB matrix participating in multiplication operation
* b       -- pointer to the contents of the seconr MATLAB matrix participating in multiplication operation
* Mi      -- number of elements in the first dimension of matrices to multiply (columns for a and rows for b matrices)
* Mj      -- number of elements in the second dimension of matrices to multiply (rosw for a and columns for b marices)
* Mk0     -- product of all remaining (except first and second) dimensions of matrix a to multiply
* Mk      -- product of all remaining (except first and second) dimensions of matrix b to multiply
* expandA -- boolean containing true if Mk0<Mk. False otherwise.
* expandB -- boolean containing true if Mk0>Mk. False otherwise.
*/
template<typename Rz, typename L, typename R>
void  mat_multiply(Rz *rez, L const *const a, R const*const b, size_t Mi, size_t Mj, size_t Mk0, size_t Mk, bool expandA, bool expandB, int n_threads)
{
    /* The original MATLAB code, which is reimplemented in C++ and indicating
    * algorithm, used to calculate the product in C++
    for j=1:11
        for i=1:4
            for k=1:6
                c0(i,j,:) = c0(i,j,:) + a(i,k,:).*b(k,j,:);
            end
        end
    end
    */
#pragma omp parallel if ((n_threads>1) &&(Mk > 4*n_threads)) num_threads(n_threads)
#pragma omp for
    for (long k = 0; k < Mk*Mi*Mj; ++k) {
        rez[k] = 0;
    }

#pragma omp for
    for (long k = 0; k < Mk; ++k) {
        size_t k0 = k*Mi*Mj;
        size_t ka = k*Mi*Mk0;
        size_t kb = k*Mk0*Mj;
        for (size_t j = 0; j < Mj; ++j) {
            size_t jib = j*Mi;
            size_t jkb = j*Mk0;
            for (size_t i = 0; i < Mi; ++i) {
                double sum = 0;
                for (size_t k1 = 0; k1 < Mk0; ++k1) {
                    if (expandA) { // A is a 2D matrix
                        sum += static_cast<double>(a[k1*Mi + i]) * static_cast<double>(b[k1 + jkb + kb]);
                    }
                    else if (expandB) { // B is a 2D matrix
                        sum += static_cast<double>(a[ka + k1*Mi + i]) * static_cast<double>(b[k1 + jkb]);
                    }
                    else {
                        sum += static_cast<double>(a[ka + k1*Mi + i]) * static_cast<double>(b[k1 + jkb + kb]);
                    }
                } //k1
                rez[k0 + i + jib] = static_cast<Rz>(sum);
            } //j
        } //i
    }

}


