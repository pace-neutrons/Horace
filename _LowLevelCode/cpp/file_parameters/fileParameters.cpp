#include "fileParameters.h"

// map used to process input file(s) parameters
const std::map<std::string, file_par> fileParameters::fileParamNames = {
    { std::string("file_name"),     file_par::file_name },
    { std::string("npix_start_pos"),file_par::npix_start_pos},
    { std::string("pix_start_pos"), file_par::pix_start_pos},
    { std::string("file_id"),       file_par::run_id },
    { std::string("nbins_total"),   file_par::nbins_total },
    { std::string("npix_total"),    file_par::npix_total },
    { std::string("pixel_with"),    file_par::pixel_with  }
};
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* return input parameters as cellarray of character arrays
*  Function used in testing fileParameters interface to Matlab
*/
void fileParameters::returnInputs(mxArray** const outParList) {
    auto out = mxCreateCellMatrix(this->num_input_params, 1);
    outParList[0] = out;
    int n_set_param(0); // number of parameter set as the result
    for (size_t i = 0; i < fileParamNames.size(); i++) {
        file_par id_num = file_par(i);
        if (!this->parameters_set[i])continue;
        switch (id_num) {
        case(file_par::file_name): {
            auto pFn = mxCreateString(this->fileName.c_str());
            mxSetCell(out, n_set_param, pFn);
            break;
        }
        case(file_par::npix_start_pos): {
            auto pVal = mxCreateDoubleScalar(double(this->nbin_start_pos));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(file_par::pix_start_pos): {
            auto pVal = mxCreateDoubleScalar(double(this->pix_start_pos));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(file_par::run_id): {
            auto pVal = mxCreateDoubleScalar(double(this->run_id));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(file_par::nbins_total): {
            auto pVal = mxCreateDoubleScalar(double(this->total_NfileBins));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(file_par::npix_total): {
            auto pVal = mxCreateDoubleScalar(double(this->total_nPixels));
            mxSetCell(out, n_set_param, pVal);
            break;
        }
        case(file_par::pixel_with): {
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
        mexErrMsgIdAndTxt(MEX_ERR_ID, buf.str().c_str());
    }
    if (number_of_fields > 7) {
        std::stringstream buf;
        buf << "each file parameter structure should contain no more then 7 fields but have: " << (short)number_of_fields << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID, buf.str().c_str());
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
            mexErrMsgIdAndTxt(MEX_ERR_ID, err.c_str());
        }

        const mxArray* pFieldContents = mxGetFieldByNumber(pFileParam, 0, field_index);
        file_par fld_id = file_par(ind);
        switch (fld_id) {
        case(file_par::file_name): {
            this->fileName = std::string(mxArrayToString(pFieldContents));
            break;
        }
        case(file_par::npix_start_pos): {
            this->nbin_start_pos = process_pix_npix_pos(pFieldContents);
            break;
        }
        case(file_par::pix_start_pos): {
            this->pix_start_pos = process_pix_npix_pos(pFieldContents);
            break;
        }
        case(file_par::run_id): {
            double* pFileID = mxGetPr(pFieldContents);
            this->run_id = int(pFileID[0]);
            break;
        }
        case(file_par::nbins_total): {
            double* pNpixTotal = mxGetPr(pFieldContents);
            this->total_NfileBins = size_t(pNpixTotal[0]);
            break;
        }
        case(file_par::npix_total): {
            double* pTotNPixels = mxGetPr(pFieldContents);
            this->total_nPixels = uint64_t(*pTotNPixels);
            break;
        }
        case(file_par::pixel_with): {
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
/** Helper function to process possible inputs for nbins and npix fields
*@inputs    pointer to pix position or nbins position
*@returns   value of pix or nbins position converted into unit64_t
*/
uint64_t fileParameters::process_pix_npix_pos(const mxArray* const pFieldContents) {
    mxClassID id = mxGetClassID(pFieldContents);
    uint64_t pos(0);
    switch (id) {
    case mxINT64_CLASS: {
        int64_t* pPixStart = (int64_t*)mxGetData(pFieldContents);
        pos = uint64_t(pPixStart[0]);
        break;
    }
    case mxUINT64_CLASS: {
        uint64_t* pPixStart = (uint64_t*)mxGetData(pFieldContents);
        pos = uint64_t(pPixStart[0]);
        break;
    }
    case mxDOUBLE_CLASS: {
        double* pPixStart = mxGetPr(pFieldContents);
        pos = uint64_t(pPixStart[0]);
        break;
    }
    default: {
        std::stringstream err_buf;
        const char* class_name = mxGetClassName(pFieldContents);
        err_buf << "unsupported type of the input data for pix_start_pos: " << class_name << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID, err_buf.str().c_str());
    }
    }
    return pos;
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
                // identify the name of the mandatory parameter which has not been provided
                auto it = std::find_if(this->fileParamNames.begin(), this->fileParamNames.end(),
                    [&i](const auto& p) {
                        return p.second == i;
                    });
                std::stringstream buf;
                buf << "value for field: " << it->first << " requested but has not been provided " << std::endl;
                mexErrMsgIdAndTxt(MEX_ERR_ID, buf.str().c_str());

            }
        };
    };
    this->num_input_params = n_params_provided;
    if (this->nbin_start_pos + this->total_NfileBins + PIX_INFO_SIZE > this->pix_start_pos) {
        std::stringstream buf;
        buf << "NBINS position at: " << this->nbin_start_pos << " plus number of bins: " << this->total_NfileBins
            << " overlaps with pixels info start position: " << this->pix_start_pos << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID, buf.str().c_str());

    }
    if (this->pix_start_pos < PIX_INFO_SIZE) {
        std::stringstream buf;
        buf << "Pix start position at: " << this->pix_start_pos << " does not allow to write 12 bytes of metadata in front of it " << std::endl;
        mexErrMsgIdAndTxt(MEX_ERR_ID, buf.str().c_str());

    }
}


