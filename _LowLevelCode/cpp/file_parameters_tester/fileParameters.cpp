#include "fileParameters.h"
// map used to process input file(s) parameters
const std::map<std::string, int> fileParameters::fileParamNames = {
    { std::string("file_name"),0 },
    { std::string("npix_start_pos"),1 },
    { std::string("pix_start_pos"),2 },
    { std::string("file_id"),3 },
    { std::string("nbins_total"),4 },
    { std::string("pixel_with"),5  }
};
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* Convert input Matlab structure with the fields, necessary to describe input & output sqw file into
 * fileParameters class.
 @input -- pointer to Matlab structure, containing the file description, with fields defined in the map above.
*/
fileParameters::fileParameters(const mxArray *pFileParam) {

    mwSize total_num_of_elements = mxGetNumberOfElements(pFileParam);
    mwSize number_of_fields      = mxGetNumberOfFields(pFileParam);

    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each field of file parameter structure should contain only one element, not: " << (short)total_num_of_elements << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }
    if (number_of_fields > 6) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each file parameter structure should contain no more then 6 fields but have: " << (short)number_of_fields << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }

    for (int field_index = 0; field_index < number_of_fields; field_index++) {
        const std::string FieldName(mxGetFieldNameByNumber(pFileParam, field_index));
        int ind(-1);
        try {
            ind = fileParamNames.at(FieldName);
        }
        catch (std::out_of_range) {
            std::string err = "ERROR::combine_sqw ==> file parameters structure contains unknown parameter: " + FieldName;
            mexErrMsgTxt(err.c_str());
        }

        const mxArray *pFieldContents = mxGetFieldByNumber(pFileParam, 0, field_index);
        switch (ind) {
        case(0): {
            fileName = std::string(mxArrayToString(pFieldContents));
            break;
        }
        case(1): {
            double *pnBin_start = mxGetPr(pFieldContents);
            nbin_start_pos = int64_t(pnBin_start[0]);
            break;
        }
        case(2): {
            double *pPixStart = mxGetPr(pFieldContents);
            pix_start_pos = uint64_t(pPixStart[0]);
            break;
        }
        case(3): {
            double *pFileID = mxGetPr(pFieldContents);
            file_id = int(pFileID[0]);
            break;
        }
        case(4): {
            double *pNpixTotal = mxGetPr(pFieldContents);
            total_NfileBins = size_t(pNpixTotal[0]);
            break;
        }
        case(5): {
            double *pPixWidth  = mxGetPr(pFieldContents);
            pixel_width = uint32_t(*pPixWidth);
            break;
        }
        default: {
            mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
        }
        }
    }
}
