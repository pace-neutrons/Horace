#include "fileParameters.h"
// map used to process input file(s) parameters
const std::map<std::string, int> fileParameters::fileParamNames = {
    { std::string("file_name"),0 },
    { std::string("npix_start_pos"),1 },
    { std::string("pix_start_pos"),2 },
    { std::string("file_id"),3 },
    { std::string("nbins_total"),4 }
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
    mwSize number_of_fields = mxGetNumberOfFields(pFileParam);

    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each field of file parameter structure should contain only one element, not: " << (short)total_num_of_elements << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }
    if (number_of_fields > 5) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each file parameter structure should contain no more then 5 fields but have: " << (short)number_of_fields << std::endl;
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

        const mxArray *pFieldCont = mxGetFieldByNumber(pFileParam, 0, field_index);
        switch (ind) {
        case(0): {
            fileName = std::string(mxArrayToString(pFieldCont));
            break;
        }
        case(1): {
            double *pnBin_start = mxGetPr(pFieldCont);
            nbin_start_pos = int64_t(pnBin_start[0]);
            break;
        }
        case(2): {
            double *pPixStart = mxGetPr(pFieldCont);
            pix_start_pos = uint64_t(pPixStart[0]);
            break;
        }
        case(3): {
            double *pFileID = mxGetPr(pFieldCont);
            file_id = int(pFileID[0]);
            break;
        }
        case(4): {
            double *pNpixTotal = mxGetPr(pFieldCont);
            total_NfileBins = size_t(pNpixTotal[0]);
            break;
        }
        default: {
            mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
        }
        }
    }
}
