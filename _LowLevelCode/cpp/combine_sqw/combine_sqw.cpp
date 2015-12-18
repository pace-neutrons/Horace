#include "combine_sqw.h"
#include <map>
#include <algorithm>
#include <numeric>

enum InputArguments {
    tmp_files_list,
    fileParam,
    programSettings,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    pix_data,
    pix_info,
    N_OUTPUT_Arguments
};
// parameters the mex file uses
struct ProgParameters {
    size_t totNumBins;  // total number of bins in files to combine (has to be the same for all files)
    size_t nBin2read;  // current bin number to read (start from 0 for first bin of the array)
    size_t pixBufferSize; // the size of the buffer to return combined pixels
};
// enum used to process input file(s) parameters
enum fileParamNumbers {
    n_bin_start = 0,
    pix_start   = 1,
    nfile_id    = 2,
    nbins_total = 3
};
// Enum describing main parameters of the data, stored in the file.
enum DATA_DESCR {
    // size of the pixel in pixel data units (float)
    PIX_SIZE  =9,
    // size of the pixel block in bytes
    PIX_BLOCK_SIZE_BYTES = 9*4,

};
void cells_in_memory::init(std::fstream  &fileDescr, size_t bin_start_pos, size_t n_tot_bins) {
    fReader = &fileDescr;
    nbin_buffer.resize(BIN_BUF_SIZE,0);
    pix_pos_in_buffer.resize(BIN_BUF_SIZE,0);
    nTotalBins      = n_tot_bins;
    binFileStartPos = bin_start_pos;
}
/* return number of pixels this bin buffer describes */
size_t cells_in_memory::num_pix_described(size_t bin_number)const {
    size_t loc_bin = bin_number - this->num_first_buf_bin;
    size_t end = BIN_BUF_SIZE - 1;
    if (loc_bin >= this->pix_pos_in_buffer.size()) {
        return pix_pos_in_buffer[end] + nbin_buffer[end];
    } else {
        size_t num_pix_start = pix_pos_in_buffer[loc_bin];
        return pix_pos_in_buffer[end] + nbin_buffer[end] - num_pix_start;
    }
}

/* return the number of pixels described by the bins fitting the buffer of the size specified*/
size_t cells_in_memory::num_pix_to_fit(size_t bin_number, size_t buf_size)const {
    size_t n_bin = bin_number-num_first_buf_bin;
    size_t shift = pix_pos_in_buffer[n_bin];
    size_t val = buf_size+ shift;
    auto begin = pix_pos_in_buffer.begin()+ n_bin;
    auto it = std::upper_bound(begin, pix_pos_in_buffer.end(), val);

    it--;
    if (it == pix_pos_in_buffer.begin()) {
        return this->nbin_buffer[0];
    } else {
        return *it- shift;
    }


}
/*
* Method to read block of information about number of pixels
* stored according to bins starting with the bin number specified
* as input
*
* num_loc_bin -- the bin within a block to read into the buffer
Returns:
absolute number of last bin read into the buffer.
*/
size_t cells_in_memory::read_bins(size_t num_bin) {
    if (num_bin >= this->nTotalBins) {
        mexErrMsgTxt("Accessing bin out of bin range");
    }

    this->num_first_buf_bin = num_bin;
    size_t bin_end = this->num_first_buf_bin + this->BIN_BUF_SIZE;

    if (bin_end > nTotalBins) {
        bin_end = nTotalBins;
    }
    this->buf_bin_end = bin_end;

    size_t  tot_num_bins_to_read = bin_end - num_bin;

    size_t bin_pos = binFileStartPos + num_bin*BIN_SIZE_BYTES;
    size_t length = tot_num_bins_to_read*BIN_SIZE_BYTES;
    char * buffer = reinterpret_cast<char *>(&nbin_buffer[0]);

    fReader->seekp(bin_pos);
    std::string err;
    try {
        fReader->read(buffer, length);
    }
    catch (std::ios_base::failure &e) {
        err = "COMBINE_SQW:read_bins read error: " + std::string(e.what());
    }
    catch (...) {
        err = "COMBINE_SQW:read_bins unhandled read error.";

    }
    if (err.size() > 0) {
        mexErrMsgTxt(err.c_str());
    }
    this->pix_pos_in_buffer[0] = 0;
    for (size_t i = 1; i < tot_num_bins_to_read; i++) {
        this->pix_pos_in_buffer[i] = this->pix_pos_in_buffer[i - 1] + this->nbin_buffer[i - 1];
    }
    return tot_num_bins_to_read;
}

void cells_in_memory::get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix) {

    //
    if (bin_number >= this->buf_bin_end) {
        this->read_all_bin_info(bin_number); // Advance cache
    }
    else if (bin_number < this->num_first_buf_bin) { // cache miss
        this->num_first_buf_bin = 0;
        this->buf_bin_end = 0;
        this->read_all_bin_info(bin_number);
    }
    size_t  num_bin_in_buf = bin_number - this->num_first_buf_bin;
    num_bin_pix = this->nbin_buffer[num_bin_in_buf];
    pix_start_num = this->sum_prev_bins + this->pix_pos_in_buffer[num_bin_in_buf];

}
void cells_in_memory::read_all_bin_info(size_t bin_number) {

    if (bin_number < this->num_first_buf_bin) { //cash missed, start reading afresh
        this->num_first_buf_bin = 0;
        this->buf_bin_end = 0;
        this->sum_prev_bins = 0;
    }
    //------------------------------------------------------------------------------
    size_t firstNewBin = this->buf_bin_end;
    size_t n_strides = (bin_number- firstNewBin)/ this->BIN_BUF_SIZE + 1;
    for (size_t i = 0; i < n_strides; i++) {
        size_t start_bin = firstNewBin+i*this->BIN_BUF_SIZE;
        this->sum_prev_bins += num_pix_described(start_bin);
        read_bins(start_bin);
     }



}
void read_pix_info(float *pPixBuffer,size_t &n_buf_pixels, size_t &n_bins_processed,
                    std::vector<sqw_reader> &fileReader,const ProgParameters &param) {

    size_t n_files = fileReader.size();
    n_buf_pixels = 0;
    size_t n_tot_bins(0);
    size_t npix, pix_start_num;


    for (size_t n_bin = param.nBin2read; n_bin < param.totNumBins; n_bin++) {
        size_t cell_pix = 0;
        for (size_t i = 0; i < n_files; i++) {
            fileReader[i].get_npix_for_bin(n_bin, pix_start_num, npix);
            cell_pix+= npix;
        }

        n_bins_processed = n_bin;
        if (cell_pix == 0)continue;

        if (cell_pix + n_buf_pixels > param.pixBufferSize) {
            n_bins_processed--;
            break;
        }


        for (size_t i = 0; i < n_files; i++) {
            fileReader[i].get_pix_for_bin(n_bin, pPixBuffer, n_buf_pixels,
                    pix_start_num, npix,true);
            n_buf_pixels  += npix;
        }
    }
}
sqw_reader::sqw_reader() :
    bin_buffer(4096),npix_in_buf_start(0), buf_pix_end(0),
    PIX_BUF_SIZE(4096)
{}

sqw_reader::sqw_reader(const std::string &infile, const fileParameters &fpar) : sqw_reader()
{
    this->init(infile,fpar);
}
void sqw_reader::init(const std::string &infile, const fileParameters &fpar){
    
    
    this->full_file_name = infile;
    this->fileDescr = fpar,

    h_data_file.open(full_file_name, std::fstream::in|std::fstream::binary);
    if (!h_data_file.is_open()) {
        std::string error("Can not open file: ");
        error += full_file_name;
        mexErrMsgTxt(error.c_str());
    }
    bin_buffer.init(h_data_file, fpar.nbin_start_pos, fpar.total_NfileBins);

    this->pix_buffer.resize(PIX_BUF_SIZE*DATA_DESCR::PIX_SIZE);

}

/* get number of pixels, stored in the bin and the position
*  of these pixels within pixel array
*
*@param bin_number -- number of pixel to get information for
*
* Returns:
* pix_start_num -- initial position of the bin pixels in the pixels array
* num_bin_pix   -- number of pixels, stored in this bin
*/

void sqw_reader::get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix) {
    this->bin_buffer.get_npix_for_bin(bin_number, pix_start_num, num_bin_pix);
}



/* return pixel information for the pixels stored in the bin 
* @param bin_number -- the bin number to get results for
*
* @returns pix_info -- array size = [9, npix] containing pixel info
*                      for the pixels, belonging to the bin requested
*/
void sqw_reader::get_pix_for_bin(size_t bin_number, float *pix_info, size_t buf_position,
    size_t &pix_start_num, size_t &num_bin_pix,bool position_is_defined) {

    if (!position_is_defined){
        this->get_npix_for_bin(bin_number, pix_start_num, num_bin_pix);
    }
    if (num_bin_pix == 0) return;

    if (pix_start_num < this->npix_in_buf_start || pix_start_num+ num_bin_pix >=this->buf_pix_end) {
        this->read_pixels(bin_number, pix_start_num);
    }

    size_t out_buf_start = buf_position*DATA_DESCR::PIX_SIZE;
    size_t in_buf_start  = (pix_start_num- this->npix_in_buf_start)*DATA_DESCR::PIX_SIZE;
    for(size_t i=0;i<num_bin_pix*DATA_DESCR::PIX_SIZE;i++){
        pix_info[out_buf_start +i]= pix_buffer[in_buf_start+i];
    }

}
/*
% read pixels information, located in the bin with the number requested
%
% read either all pixels in the buffer or at least the number
% specified
%
*/
void sqw_reader::read_pixels(size_t bin_number, size_t pix_start_num) {


    //check if we have loaded enough bin information to read enough
    //pixels and return enough pixels to fill - in buffer.Expand or
    // shrink if necessary
    // if we are here, nbin buffer is intact and pixel buffer is
    // invalidated
   size_t num_pix_to_read = this->check_binInfo_loaded_(bin_number);

   size_t pix_pos = this->fileDescr.pix_start_pos +  pix_start_num*DATA_DESCR::PIX_BLOCK_SIZE_BYTES;
   h_data_file.seekp(pix_pos);
   char * buffer = reinterpret_cast<char *>(&pix_buffer[0]);
   size_t length = num_pix_to_read*DATA_DESCR::PIX_BLOCK_SIZE_BYTES;
   std::string err;
   try{
    h_data_file.read(buffer, length);
   }catch (std::ios_base::failure &e) {
      err = "COMBINE_SQW:read_pixels read error: "+std::string(e.what());
   }catch (...) {
      err = "COMBINE_SQW:read_pixels unhandled read error. ";
   }
   if (err.size() > 0) {
       mexErrMsgTxt(err.c_str());
   }
   if (this->fileDescr.file_id > 0) {
       for (size_t i = 0; i < num_pix_to_read; i++) {
            this->pix_buffer[5+i*9] = float(this->fileDescr.file_id);
       }

   }
   this->npix_in_buf_start = pix_start_num;
   this->buf_pix_end = this->npix_in_buf_start+ num_pix_to_read+1;


}
/*
% verify bin information loaded to memory and identify sufficient number
% of pixels to fill - in pixels buffer.
%
% read additional bin information if not enough bins have been
% processed
%
*/
size_t sqw_reader::check_binInfo_loaded_(size_t bin_number) {

    // assume bin buffer is intact with bin_number loaded
    size_t num_pix_to_read = this->bin_buffer.num_pix_described(bin_number);

    if (num_pix_to_read > this->PIX_BUF_SIZE) {
        num_pix_to_read = this->bin_buffer.num_pix_to_fit(bin_number, PIX_BUF_SIZE);
    } else {
        if (num_pix_to_read > this->PIX_BUF_SIZE) {
            this->PIX_BUF_SIZE = num_pix_to_read;
            // npix buffer should be extended
            this->pix_buffer.resize(this->PIX_BUF_SIZE*DATA_DESCR::PIX_SIZE);
        }else {
            /*
             % let's do nothing for the time being
             %    last_loc_pix_number = self.pix_pos_in_buffer_(end - 1);
             %    while (num_pix_to_read < self.pix_buf_size_ + pix_buf_position && last_loc_pix_number<self.num_bins_)
             % self.read_bin_info_(last_loc_pix_number, 'expand')
             % last_loc_pix_number = first_bin_number + self.BIN_BUF_SIZE_ - 1;
            %        num_pix_to_read = self.pix_pos_in_buffer_(last_loc_pix_number) - pix_buf_position;
            %    end
                %    if num_pix_to_read > self.pix_buf_size_
                %        last_loc_pix_number = find(self.pix_pos_in_buffer_ <= self.buf_size_ + pix_buf_position, 1, 'last');
            %    end
            */

        }
    }
    return num_pix_to_read;

}

fileParameters processFileParam(const mxArray *pFileParam, const std::map<const std::string, fileParamNumbers> &fieldNamesMap) {

    mwSize total_num_of_elements = mxGetNumberOfElements(pFileParam);
    mwSize number_of_fields = mxGetNumberOfFields(pFileParam);

    if (total_num_of_elements != 1) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each field of file parameter structure should contain only one element, not" << (short)total_num_of_elements << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }
    if (number_of_fields != 3) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw ==> each file parameter structure should contain 3 fields but have: " << (short)number_of_fields << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }

    fileParameters result;
    for (int field_index=0; field_index<3; field_index++){
        std::string    FieldName = std::string(mxGetFieldNameByNumber(pFileParam, field_index));
        const mxArray *pFieldCont = mxGetFieldByNumber(pFileParam,0, field_index);
        auto it = fieldNamesMap.find(FieldName);
        if (it == fieldNamesMap.end()) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw ==> file parameters structure contains unknown parameter: " << FieldName << std::endl;
            mexErrMsgTxt(buf.str().c_str());

        }

        fileParamNumbers id = it->second;
        switch (id) {
            case(fileParamNumbers::n_bin_start):{
                double *pnBin_start = mxGetPr(pFieldCont);
                result.nbin_start_pos = int64_t(pnBin_start[0]);
                break;
                }
            case(fileParamNumbers::pix_start) : {
                double *pPixStart = mxGetPr(pFieldCont);
                result.pix_start_pos = int64_t(pPixStart[0]);
                break;
                }
            case(fileParamNumbers::nfile_id) :{
                double *pFileID = mxGetPr(pFieldCont);
                result.file_id = int(pFileID[0]);
                }
        }
    }
    return result;
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision:: 1063 $ ($Date:: 2015-10-22 20:18:41 +0100 (Thu, 22 Oct 2015) $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }
    bool debug_file_reader(false);
    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments&&nrhs != N_INPUT_Arguments - 1) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs == 2) {
            debug_file_reader = true;
        }
        /*
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
        */
    }
    /********************************************************************************/
    /* retrieve input parameters */
    // Pointer to list of files to process
    auto pFileList      = prhs[tmp_files_list];
    mxClassID  category = mxGetClassID(pFileList);
    if (category != mxCELL_CLASS)mexErrMsgTxt("Input files list has to be packed in cellarray");

    size_t n_files = mxGetNumberOfElements(pFileList);
    size_t n_realFiles = 0;
    std::vector<std::string> fileName(n_files);
    for (size_t i = 0; i < n_files; i++) {
        const mxArray *pCellElement;
        pCellElement = mxGetCell(pFileList,i);
        if (pCellElement == NULL) { // empty cell
            continue;
        }
        if (mxCHAR_CLASS != mxGetClassID(pCellElement)) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw => all cells in the input file list have to be filenames but element N" << i << " is not\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        mwSize buflen = mxGetNumberOfElements(pCellElement) + 1;
        std::vector<char> fnameBuffer(buflen);
        mxGetString(pCellElement,&fnameBuffer[0],buflen);

        fileName[n_realFiles] = std::string(&fnameBuffer[0]);
        n_realFiles++;
    }
    // Pointer to list of file parameters to process. The parameters will change as
    // module takes more from Matlab code
    auto pParamList = prhs[fileParam];
    size_t nfParams = mxGetNumberOfElements(pParamList);
    if (nfParams != n_files) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw => Number of file parameters: "<< nfParams<<" is not equal to number of files: "<< n_files<<std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }

    // Retrieve programs parameters
    ProgParameters ProgSettings;
    auto pProg_settings = (double *)mxGetPr(prhs[programSettings]);
    for (size_t i = 0; i < 3; i++) {
        switch (i) {
            case(0):
                ProgSettings.totNumBins = size_t(pProg_settings[i]);
                break;
            case(1):
                // -1 --> convert to C-arrays from Matlab array counting
                ProgSettings.nBin2read = size_t(pProg_settings[i])-1;
                break;
            case(2) :
                ProgSettings.pixBufferSize = size_t(pProg_settings[i]);
        }

    }

    std::map<const std::string, fileParamNumbers> fileParamNames;
    fileParamNames["npix_start_pos"] = fileParamNumbers::n_bin_start;
    fileParamNames["pix_start_pos"] = fileParamNumbers::pix_start;
    fileParamNames["file_id"] = fileParamNumbers::nfile_id;


    size_t n_realParam = 0;
    std::vector<fileParameters> fileParam(nfParams);
    for (size_t i = 0; i < nfParams; i++) {
        const mxArray *pCellElement;
        pCellElement = mxGetCell(pParamList, i);
        if (pCellElement == NULL) { // empty cell
            continue;
        }
        if (mxSTRUCT_CLASS != mxGetClassID(pCellElement)) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw => all cells in the input parameter list have to be structures but element N" << i << " is not\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        fileParam[n_realParam] = processFileParam(pCellElement, fileParamNames);
        fileParam[n_realParam].total_NfileBins = ProgSettings.totNumBins;
        n_realParam++;
    }

    if (n_realParam != n_realFiles) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw => Number of defined file parameters: " << nfParams << " not equal to number of defined files: " << n_files << std::endl;
        mexErrMsgTxt(buf.str().c_str());
    }
    //--------------------------------------------------------
    std::vector<sqw_reader> fileReader(n_files);
    for (size_t i = 0; i < n_files; i++) {
        fileReader[i].init(fileName[i], fileParam[i]);
    }
    size_t n_buf_pixels(0),n_bins_processed(0);
    if (debug_file_reader) {
        auto PixBuffer = mxCreateNumericMatrix(9, ProgSettings.pixBufferSize, mxSINGLE_CLASS, mxREAL);
        if (!PixBuffer) {
            mexErrMsgTxt("Can not allocate output pixels buffer");
        }
        float *pPixBuffer = (float *)mxGetPr(PixBuffer);

        read_pix_info(pPixBuffer, n_buf_pixels, n_bins_processed, fileReader, ProgSettings);
        auto OutParam = mxCreateNumericMatrix(2, 1, mxUINT64_CLASS, mxREAL);
        uint64_t *outData = (uint64_t *)mxGetPr(OutParam);
        outData[0] = n_buf_pixels;
        outData[1] = n_bins_processed;

        plhs[pix_data] = PixBuffer;
        plhs[pix_info] = OutParam;
    }
    else {

    }
}

