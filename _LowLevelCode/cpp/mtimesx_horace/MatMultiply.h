#pragma once
#include "../CommonCode.h"

enum MatrixTypes
{
    double_double,
    double_single,
    single_double,
    single_single,
    unsupported
};
/* function defines the type of matrix multiplication as the function of types of input matrix */
typedef std::pair<MatrixTypes, mxClassID> operations;
operations  get_op_type(mxArray const *const mat_a, mxArray const *const mat_b);

/* calculate the capacity of higher dimensions of an nD>2 array*/
size_t calc_mdims(mwSize const *const dimsA, size_t ndimsA);

/* Calculate size and the dimensionality of the resulting array */
void calc_output_size(mwSize const *const dimsA, size_t ndimsA, mwSize const *const  dimsB, size_t ndimsB,
    std::vector<mwSize> & rez_dim_sizes, size_t &nDims, size_t &Mk, bool & expandA, bool &expandB);


/* multiply two matrices or array of matrices */
template<typename Rz, typename L, typename R>
void  mat_multiply(Rz *rez, L const *const a, R const*const b, size_t Mi, size_t Mj, size_t Mk0, size_t Mk, bool expandA, bool expandB, int n_threads)
{

    /*
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


