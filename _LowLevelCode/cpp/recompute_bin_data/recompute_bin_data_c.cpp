#include <float.h>
#include <limits>
#include <sstream>
#include <cmath>
#include <omp.h>
//
#include <mex.h>
#include <matrix.h>
#include <cfloat>


enum InputArguments {
    Pixel_data,
    Signal,
    Error,
    Npixels,
    CoordRotation_matrix,
    CoordShif_matrix,
    Scale_energy,
    Shift_energy,
    DataCut_range,
    Plot_axis,
    Program_settings,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    Actual_Pix_Range,
    Pixels_Ok,
    Pixels_Ind,
    Signal_modified,
    Error_Modified,
    Npixels_out,
    Npix_Retained,
    N_OUTPUT_Arguments
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision:: 876  $ ($Date:: 2014-06-10 12:31:44 +0100 (Tue, 10 Jun 2014) $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }

    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments&&nrhs != N_INPUT_Arguments - 1) {
            std::stringstream buf;
            buf << "ERROR::recompute_bin_data_c needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs != N_OUTPUT_Arguments) {
            std::stringstream buf;
            buf << "ERROR::recompute_bin_data_c needs " << (short)N_OUTPUT_Arguments << " outputs but requested to return" << (short)nlhs << " arguments\n";
            mexErrMsgTxt(buf.str().c_str());
        }

        for (int i = 0; i < nrhs - 1; i++) {
            if (prhs[i] == NULL) {
                std::stringstream buf;
                buf << "ERROR::recompute_bin_data_c => argument N" << i << " undefined\n";
                mexErrMsgTxt(buf.str().c_str());
            }
        }
    }
}