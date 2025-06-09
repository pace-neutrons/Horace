#include <include/CommonCode.h>
#include "fileParameters.h"
#include <utility/version.h>



void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nrhs == 0 && (nlhs == 1||nlhs == 0)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }
    if (nlhs == 0) {
        return;
    }
    fileParameters par(prhs[0]);
    par.returnInputs(plhs);

}

