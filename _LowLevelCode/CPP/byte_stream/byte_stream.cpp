#include "mex.h"
 
EXTERN_C mxArray* mxSerialize(mxArray const *);
EXTERN_C mxArray* mxDeserialize(const void *, size_t);

/** function provides access to internal serialize-deserialize routines 
* Based on non-documented Matlab API function mxSerialize/mxDeserialize not available in latest Matlab 
* versions so not compiler-able and probably fails in recent Matlab versions, which do not expose this
* functions.
* Usage: 
*array = byte_stream(object,'S'); -- convert an object into byte stream array
*obj   = byte_stream(array,'D');  -- do the opposite and convert previously obtained byte stream array into the originating object
*
*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{


    const char REVISION[]="$Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)";
    if(nrhs==0&&nlhs==1){
        plhs[0]=mxCreateString(REVISION); 
        return;
    }

    bool serialize(true);
    if (nlhs && nrhs) {
        if (nrhs == 1) {
            serialize = true;
        }else{
            mxChar * pMode = mxGetChars(prhs[1]);
            if (*pMode == 's' || *pMode=='S'){
                serialize = true;
            }
            else if (*pMode == 'd' || *pMode=='D'){
                serialize = false;
            }else{
                mexErrMsgTxt("Unknown conversion mode provided, ony S[erialize] and D[eserialize] modes are supported");
            }
            
        }

    }
    if (serialize)
    {
        plhs[0] = (mxArray *) mxSerialize(prhs[0]);
    }else{ // deserialize
        plhs[0] = (mxArray *) mxDeserialize(mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
    }

}

