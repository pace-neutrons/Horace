#pragma once
#include "CommonCode.h"
#include <tuple>

enum MatrixTypes
{
    double_double,
    double_single,
    single_double,
    single_single,
    unsupported
};
/* function defines the type of matrix multiplication as the function of types of input matrix */
std::tuple<MatrixTypes, mxClassID>  get_op_type(mxArray const *const mat_a, mxArray const *const mat_b);

/* calculate the capacity of higher dimensions of an nD>2 array*/
size_t calc_mdims(mwSize const *const dimsA, size_t ndimsA);

/* Calculate size and the dimensionality of the resulting array */
void calc_output_size(mwSize const *const dimsA, size_t ndimsA, mwSize const *const  dimsB, size_t ndimsB,
    std::vector<size_t> & rez_dim_sizes,size_t &nDims,size_t &Mk, bool & expandA, bool &expandB);


/* multiply two matrices or array of matrices */
template<typename Rz, typename L, typename R>
void  mat_multiply(Rz *rez, L const *const a, R const*const b, size_t Mi, size_t Mj, size_t Mk, bool expandA, bool expandB, int n_threads)
{

    /*
        for i = 1:4
            for j = 1 : 11
                for k = 1 : 6
                    c0(i, j, :) = c0(i, j, :) + a(i, k, :).*b(k, j, :);
                end
            end
        end
    */
#pragma omp parallel if (Mk > 4*n_threads) num_threads(n_threads)
#pragma omp for
    for (long k=0;k<Mk*Mi*Mj;++k) {
        rez[k] = 0;
    }

#pragma omp for
    for (long k = 0; k < Mk; ++k) {
        size_t k0 = k*Mi*Mj;
        for (size_t i = 0; i < Mi*Mj; ++i) {
            double sum = 0;
            for (size_t j1 = 0; j1 < Mj; ++j1) {
                size_t jb = j1*Mi;
                for (size_t i1 = 0; i1 < Mi; ++i1) {
                    if (expandA) {
                        sum += a[j1*Mi + i] * b[k0 + jb + i1];
                    }
                    else if (expandB) {
                        sum += a[k0 + j1*Mi + i] * b[jb + i1];
                    }
                    else {
                        sum += a[k0 + j1*Mi + i] * b[k0 + jb + i1];
                    }
                }
            }
            rez[k0 + i] = static_cast<Rz>(sum);
        }
    }

}


