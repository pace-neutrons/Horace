#pragma once
#include <cstdint>
#include <string>
#include <map>
#include <stdio.h>
#include <sstream>
#include <vector>
#include <algorithm>
// Matlab's includes
#include <mex.h>
#include <matrix.h>
#include <limits>


/* Class provides informatiob about target file to combine multiple pixel data in it or
   write binary pixel data*/
class fileParameters {
public:
    std::string fileName;
    uint64_t    nbin_start_pos;  // the initial file position where nbin array is located in the file
    uint64_t    pix_start_pos;   // the initial file position where the pixel array is located in file
    int         run_id;          // the number which used to identify pixels, obtained from this particular file
    size_t      total_NfileBins; // the number of bins in this file (has to be the same for all files)
    size_t      total_nPixels;   // total number of pixels to be written in the file
    uint32_t    pixel_width;     // the number of bytes in pixel. By default 9*4 (9 32byte values) but changes for compressed pixels


    fileParameters(const mxArray* pFileParam);
    fileParameters() :fileName(""), nbin_start_pos(0), pix_start_pos(12),
        run_id(0), total_NfileBins(0), total_nPixels(std::numeric_limits<size_t>::max()),
        pixel_width(36),
        parameters_set(7, false),
        num_input_params(0)
    {}
    // helper function to return to matlab inputs during class testing
    void returnInputs(mxArray** const outPar);
    void check_inputs_provided();
private:
    static const std::map<std::string, int> fileParamNames;
    // how many parameterw were set in input operations
    int num_input_params;
    // auxiliary variable containing true for each parameter set st of the parameters set during input
    std::vector<bool> parameters_set;


    // array of input keys, which define which file parameters are mandatory (value true),
    //  and which are optional (value false)
    static const bool param_requested[];
    // string which defines error ID, errors in this code are throwing.
    static const std::string MEX_ERR_ID;
    // helper function to process input parameters which define pix or npix position
    uint64_t process_pix_npix_pos(const mxArray *const pFieldContents);
};
