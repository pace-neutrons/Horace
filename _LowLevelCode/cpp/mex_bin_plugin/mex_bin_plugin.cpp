#include <include/CommonCode.h>
#include "bin_io_handler.h"

#include <utility/version.h>

//--------------------------------------------------------------------------------------------------------------------
//----------- PIX WRITER ---------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/*Initialize writer parameters
Input:
@param fpar           -- input parameters describing the output file
@param n_bins2process -- number of bins to process (combine)
*/
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }

}