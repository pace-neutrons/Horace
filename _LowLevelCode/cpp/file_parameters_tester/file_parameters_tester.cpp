#include "../CommonCode.h"
#include "filePapameters.h"


void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    if (nrhs == 0 && (nlhs == 0 || nlhs == 1)) {
        plhs[0] = mxCreateString(Horace::VERSION);
        return;
    }
}

