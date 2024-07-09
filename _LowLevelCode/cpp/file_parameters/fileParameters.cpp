#include "fileParameters.h"
// map used to process input file(s) parameters
const std::map<std::string, int> fileParameters::fileParamNames = {
    { std::string("file_name"),0 },
    { std::string("npix_start_pos"),1 },
    { std::string("pix_start_pos"),2 },
    { std::string("file_id"),3 },
    { std::string("nbins_total"),4 },
    { std::string("npix_total"),5 },
    { std::string("pixel_with"),6  }
};
const bool fileParameters::param_requested[] = {true,false,true,false,false,false,false};
const std::string fileParameters::MEX_ERR_ID("HORACE:fileParameters:invalid_argument");
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* return input parameters as cellarray of character arrays
*  Function used in testing fileParameters interface to Matlab
*/
void fileParameters ::returnInputs(mxArray** const outParList) {
    auto out = mxCreateCellMatrix(this->num_input_params,1);
    outParList[0] = out;
    int n_set_param(0); // number of parameter set as the result
    for (size_t i = 0; i < fileParamNames.size(); i++) {
        if (!this->parameters_set[i])continue;
        switch (i) {
        case(0): {
            auto pFn = mxCreateString(this->fileName.c_str());
            mxSetCell(out, n_set_param, pFn);
            break;
        }
        case(1): {
			auto pVal = mxCreateDoubleScalar(double(this->nbin_start_pos));
			mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(2): {
            auto pVal = mxCreateDoubleScalar(double(this->pix_start_pos));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(3): {
			auto pVal = mxCreateDoubleScalar(double(this->run_id));
			mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(4): {
			auto pVal = mxCreateDoubleScalar(double(this->total_NfileBins));
			mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(5): {
			auto pVal = mxCreateDoubleScalar(double(this->total_nPixels));
			mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(6): {
			auto pVal = mxCreateDoubleScalar(double(this->pixel_width));
			mxSetCell(out, n_set_param, pVal);
            break;
        }
        default: {
            mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
        }
        };
        n_set_param++;
    };
}
/* Convert input Matlab structure with the fields, necessary to describe input & output sqw file into
 * fileParameters class.
 @input -- pointer to Matlab structure, containing the file description, with fields defined in the map above.
*/
fileParameters::fileParameters(const mxArray* pFileParam) :
    fileParameters()
{

    mwSize total_num_of_elements = mxGetNumberOfElements(pFileParam);
    mwSize number_of_fields = mxGetNumberOfFields(pFileParam);

    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "each field of file parameter structure should contain only one element, not: " << (short)total_num_of_elements << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID.c_str(),buf.str().c_str());
    }
    if (number_of_fields > 7) {
        std::stringstream buf;
        buf << "each file parameter structure should contain no more then 7 fields but have: " << (short)number_of_fields << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID.c_str(),buf.str().c_str());
    }

    for (int field_index = 0; field_index < number_of_fields; field_index++) {
        const std::string FieldName(mxGetFieldNameByNumber(pFileParam, field_index));
        int ind(-1);
        try {
            ind = fileParamNames.at(FieldName);
            this->parameters_set[ind] = true;
        }
        catch (std::out_of_range) {
            std::string err = "file parameters structure contains unknown parameter: " + FieldName;
            mexErrMsgIdAndTxt(MEX_ERR_ID.c_str(),err.c_str());
        }

        const mxArray* pFieldContents = mxGetFieldByNumber(pFileParam, 0, field_index);
        switch (ind) {
        case(0): {
            this->fileName = std::string(mxArrayToString(pFieldContents));
            break;
        }
        case(1): {
            double* pnBin_start = mxGetPr(pFieldContents);
            this->nbin_start_pos = int64_t(pnBin_start[0]);
            break;
        }
        case(2): {
            double* pPixStart = mxGetPr(pFieldContents);
            this->pix_start_pos = uint64_t(pPixStart[0]);
            break;
        }
        case(3): {
            double* pFileID = mxGetPr(pFieldContents);
            this->run_id = int(pFileID[0]);
            break;
        }
        case(4): {
            double* pNpixTotal = mxGetPr(pFieldContents);
            this->total_NfileBins = size_t(pNpixTotal[0]);
            break;
        }
        case(5): {
            double* pTotNPixels = mxGetPr(pFieldContents);
            this->total_nPixels = uint64_t(*pTotNPixels);
            break;
        }
        case(6): {
            double* pPixWidth = mxGetPr(pFieldContents);
            this->pixel_width = uint32_t(*pPixWidth);
            break;
        }
        default: {
            mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
        }
        }
    }

    this->check_inputs_provided();
}
/* Validate if user provided all requested inputs and consistency between some of these inputs
*/
void fileParameters::check_inputs_provided() {
    int n_params_provided(0);
    for (size_t i = 0; i < this->parameters_set.size(); i++) {
        if (this->parameters_set[i]) {
            n_params_provided++;
        }
        else {
            if (this->param_requested[i]) {
                // idenfity the name of the parameter which has not been provided
                auto it = std::find_if(std::begin(this->fileParamNames), std::end(this->fileParamNames),
                    [&i](const auto& p) {
                        return p.second == i;
                    });
                std::stringstream buf;
                buf << "value for field: " << it->first << " requested but has not been provided " << std::endl;
                mexErrMsgIdAndTxt(MEX_ERR_ID.c_str(), buf.str().c_str());

            }
        };
    };
    this->num_input_params = n_params_provided;
    if (this->nbin_start_pos + this->total_NfileBins > this->pix_start_pos) {
        std::stringstream buf;
        buf << "NBINS position at: "<< this->nbin_start_pos << " plus number of bins: " << this->total_NfileBins 
            << " overlaps with pixels info start position: " << this->pix_start_pos << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID.c_str(), buf.str().c_str());

    }
}


