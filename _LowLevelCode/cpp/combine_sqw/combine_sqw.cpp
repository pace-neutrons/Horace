#include "combine_sqw.h"
#include <algorithm>
#include <numeric>
#include <ctime>
#include <iomanip>

enum InputArguments {
    inFileParams,
    outFileParams,
    programSettings,
    N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
    pix_data,
    pix_info,
    N_OUTPUT_Arguments
};
// parameters the mex file uses and accepts in the array of input parameters
struct ProgParameters {
    size_t totNumBins;  // total number of bins in files to combine (has to be the same for all files)
    size_t nBin2read;  // current bin number to read (start from 0 for first bin of the array)
    size_t pixBufferSize; // the size of the buffer to return combined pixels
    int log_level;       // the number defines how talkative program is. usually it its > 1 all 
                        // all diagnostics information gets printed
    size_t num_log_ticks; // how many times per combine files to print log message about completion percentage
    // Default constructor
    ProgParameters():totNumBins(0), nBin2read(0),
        pixBufferSize(10000000),log_level(1), num_log_ticks(100)
        {};
};

// Enum describing main parameters of the data, stored in the file.
enum DATA_DESCR {
    // size of the pixel in pixel data units (float)
    PIX_SIZE  =9,
    // size of the pixel block in bytes
    PIX_BLOCK_SIZE_BYTES = 9*4,

};
// map used to process input file(s) parameters
const std::map<std::string, int> fileParameters::fileParamNames = {
    {std::string("file_name"),0 },
    {std::string("npix_start_pos"),1},
    {std::string("pix_start_pos"),2},
    {std::string("file_id"),3},
    {std::string("nbins_total"),4}
};

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
void sqw_pix_writer::init(const fileParameters &fpar) {

    this->filename = fpar.fileName;
    this->h_out_sqw.open(fpar.fileName,std::ofstream::binary| std::ofstream::out|std::ofstream::app);
    if (!this->h_out_sqw.is_open()) {
        std::string err = "SQW_PIX_WRITER: Can not open target sqw file: " + fpar.fileName;
        mexErrMsgTxt(err.c_str());
    }

    this->last_pix_written =0;
    this->pix_array_position = fpar.pix_start_pos;
    this->nbin_position = fpar.nbin_start_pos;

    this->pix_buffer.resize(PIX_BUF_SIZE*PIX_SIZE);


}
void sqw_pix_writer::write_pixels(const size_t n_pix_to_write) {

    char * buffer = reinterpret_cast<char *>(&pix_buffer[0]);
    size_t length = n_pix_to_write*DATA_DESCR::PIX_BLOCK_SIZE_BYTES;
    size_t pix_pos = pix_array_position+ last_pix_written*DATA_DESCR::PIX_BLOCK_SIZE_BYTES;
    //
    this->h_out_sqw.seekp(pix_pos);
    //
    this->h_out_sqw.write(buffer,length);
    last_pix_written += n_pix_to_write;

}
sqw_pix_writer::~sqw_pix_writer() {
    this->h_out_sqw.close();
}
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
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
//
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
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------

void read_pix_info(float *pPixBuffer,size_t &n_buf_pixels, size_t &n_bins_processed,
                    std::vector<sqw_reader> &fileReader,
                    const size_t first_bin,const size_t nBinsTotal, size_t pix_buf_size) {

    size_t n_files = fileReader.size();
    n_buf_pixels = 0;
    size_t n_tot_bins(0);
    size_t npix, pix_start_num;
    //
    bool common_position(false);
    if (n_files == 1) {
        common_position = true;
    }


    for (size_t n_bin = first_bin; n_bin < nBinsTotal; n_bin++) {
        size_t cell_pix = 0;
        for (size_t i = 0; i < n_files; i++) {
            fileReader[i].get_npix_for_bin(n_bin, pix_start_num, npix);
            cell_pix+= npix;
        }

        n_bins_processed = n_bin;
        if (cell_pix == 0)continue;

        if (cell_pix + n_buf_pixels > pix_buf_size) {
            n_bins_processed--;
            break;
        }


        for (size_t i = 0; i < n_files; i++) {
            fileReader[i].get_pix_for_bin(n_bin, pPixBuffer, n_buf_pixels,
                    pix_start_num, npix, common_position);
            n_buf_pixels  += npix;
        }
    }
}
/* combine range of input sqw files into single output sqw file */
void combine_sqw(ProgParameters &param, std::vector<sqw_reader> &fileReaders, const fileParameters &outPar) {

    sqw_pix_writer pixWriter(param.pixBufferSize);
    pixWriter.init(outPar);

    int log_level= param.log_level;
    size_t num_output_ticks = param.num_log_ticks;

    std::clock_t c_start;
    if (log_level>-1){
        c_start = std::clock();
    }

    size_t start_bin = param.nBin2read;
    size_t n_bins_total = param.totNumBins;
    size_t pix_buffer_size = param.pixBufferSize;

    size_t n_bins_processed(0);
    size_t n_pixels_processed(0);
    size_t break_step = n_bins_total / num_output_ticks;
    size_t break_count(0);
    size_t break_point = break_step;
    while (n_bins_processed < n_bins_total-1) {
        float *pBuffer = pixWriter.get_pBuffer();
        size_t n_buf_pixels(0);
        read_pix_info(pBuffer, n_buf_pixels, n_bins_processed, fileReaders,
            start_bin, n_bins_total, pix_buffer_size);

        pixWriter.write_pixels(n_buf_pixels);
        start_bin = n_bins_processed+1;
        //------------Logging and interruptions ---
        break_count+= n_bins_processed;
        n_pixels_processed+= n_buf_pixels;
        if (break_count >= break_point) {
            break_point+= break_step;
            if (log_level>-1){
                std::clock_t c_end = std::clock();
                std::stringstream buf;
                buf<<"MEX::COMBINE_SQW: Completed "<< std::setw(4)<< std::setprecision(3)
                   <<float(100* n_bins_processed)/float(n_bins_total)
                   << "%  of task in "<< std::setprecision(0) <<std::setw(6) << (c_end - c_start) / CLOCKS_PER_SEC <<" sec\n";

                mexPrintf("%s",buf.str().c_str());
                //mexEvalString("drawnow");
                mexEvalString("pause(.002);");
            }
            if (utIsInterruptPending()) {
                mexWarnMsgIdAndTxt("COMBINE_SQW:interrupted", "==> C-code interrupted by CTRL-C");
                return;
            }
        }

    }
    if (log_level > -1) {
        std::clock_t c_end = std::clock();
        std::stringstream buf;
        buf << "MEX::COMBINE_SQW: Completed combining file with " << n_bins_total << " bins and "<< n_pixels_processed
            << " pixels in " << std::setw(6) << (c_end - c_start) / CLOCKS_PER_SEC << " sec\n";
        mexPrintf("%s",buf.str().c_str());
    }


}

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------

sqw_reader::sqw_reader() :
    bin_buffer(4096),npix_in_buf_start(0), buf_pix_end(0),
    PIX_BUF_SIZE(4096), change_fileno(false), fileno(true)
{}

sqw_reader::sqw_reader(const fileParameters &fpar, bool changefileno, bool fileno_provided)
    : sqw_reader()
{
    this->init(fpar, changefileno, fileno_provided);
}
void sqw_reader::init(const fileParameters &fpar,bool changefileno,bool fileno_provided){
    
    
    this->full_file_name = fpar.fileName;
    this->fileDescr = fpar;
    this->change_fileno = changefileno;
    this->fileno  = fileno_provided;

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
   if (this->change_fileno) {
       for (size_t i = 0; i < num_pix_to_read; i++) {
           if (fileno) {
               this->pix_buffer[4 + i * 9]  = float(this->fileDescr.file_id);
           }else{
               this->pix_buffer[4 + i * 9] += float(this->fileDescr.file_id);
           }
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

//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* Convert input Matlab structure with the fields, described by */
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

    for (int field_index=0; field_index<number_of_fields; field_index++){
        const std::string FieldName(mxGetFieldNameByNumber(pFileParam, field_index));
        int ind(-1);
        try {
            ind = fileParamNames.at(FieldName);
        }catch (std::out_of_range) {
            std::string err = "ERROR::combine_sqw ==> file parameters structure contains unknown parameter: " + FieldName;
            mexErrMsgTxt(err.c_str());
        }

        const mxArray *pFieldCont = mxGetFieldByNumber(pFileParam, 0, field_index);
        switch (ind) {
            case(0) : {
                fileName = std::string(mxArrayToString(pFieldCont));
                break;
            }
            case(1):{
                double *pnBin_start = mxGetPr(pFieldCont);
                nbin_start_pos = int64_t(pnBin_start[0]);
                break;
                }
            case(2) : {
                double *pPixStart = mxGetPr(pFieldCont);
                pix_start_pos = int64_t(pPixStart[0]);
                break;
                }
            case(3) :{
                double *pFileID = mxGetPr(pFieldCont);
                file_id = int(pFileID[0]);
                break;
                }
            case(4) :{
                double *pNpixTotal = mxGetPr(pFieldCont);
                total_NfileBins = size_t(pNpixTotal[0]);
                break;
                }
           default:{
              mexWarnMsgTxt("combine_sqw: unknown parameter (should never happen)");
              }
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    const char REVISION[] = "$Revision::      $ ($Date::                                              $)";
    if (nrhs == 0 && nlhs == 1) {
        plhs[0] = mxCreateString(REVISION);
        return;
    }
    //--------------------------------------------------------
    //-------   PROCESS PARAMETERS   -------------------------
    //--------------------------------------------------------

    bool debug_file_reader(false);
    size_t n_prog_params(3);
    // if pixel's run numbers id should be renamed and in which manned
    bool change_fileno(false), fileno_provided(true);
    // how many times print diagnostic message during file combining
    size_t num_output_ticks(100);
    int log_level;
    //* Check for proper number of arguments. */
    {
        if (nrhs != N_INPUT_Arguments) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
                << " input arguments and " << (short)nlhs << " output argument(s)\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        if (nlhs == 2) {
            debug_file_reader = true;
        }
        n_prog_params = mxGetN(prhs[programSettings]);
        if (!(n_prog_params == 4 || n_prog_params == 7)) {
            std::string err= "ERROR::combine_sqw => array of program parameter settings (input N 3) should have form 4 or 7 elements but got: "+
                    std::to_string(n_prog_params);
            mexErrMsgTxt(err.c_str());
        }

    }
    /********************************************************************************/
    /* retrieve input parameters */
    // Pointer to list of file parameters to process. The parameters may change as
    // module takes more from Matlab code
    auto pParamList = prhs[inFileParams];
    mxClassID  category = mxGetClassID(pParamList);
    if (category != mxCELL_CLASS)mexErrMsgTxt("Input file parameters have to be packed in cellarray");

    size_t n_files = mxGetNumberOfElements(pParamList);
    size_t n_realFiles = 0;
    std::vector<fileParameters> fileParam(n_files);
    for (size_t i = 0; i < n_files; i++) {
        const mxArray *pCellElement;
        pCellElement = mxGetCell(pParamList,i);
        if (pCellElement == NULL) { // empty cell
            continue;
        }
        if (mxSTRUCT_CLASS != mxGetClassID(pCellElement)) {
            std::stringstream buf;
            buf << "ERROR::combine_sqw => all cells in the input parameter list have to be structures but element N" << i << " is not\n";
            mexErrMsgTxt(buf.str().c_str());
        }
        fileParam[n_realFiles] = fileParameters(pCellElement);
        n_realFiles++;
    }

    // Retrieve programs parameters
    ProgParameters ProgSettings;

    auto pProg_settings = (double *)mxGetPr(prhs[programSettings]);

    for (size_t i = 0; i < n_prog_params; i++) {
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
                break;
            case(3) :
                ProgSettings.log_level = int(pProg_settings[i]);
                break;
            case(4) :
                change_fileno=bool(pProg_settings[i]);
                break;
            case(5):
                fileno_provided = bool(pProg_settings[i]);
                break;
            case(6):
                ProgSettings.num_log_ticks = size_t(pProg_settings[i]);
                break;

        }
    }
    // set up the number of bins, which is currently equal for all input files
    for (size_t i = 0; i < n_files; i++) {
        fileParam[i].total_NfileBins = ProgSettings.totNumBins;
    }


    // Pointer to output file parameters;
    auto pOutFileParams = prhs[outFileParams];
    if (mxSTRUCT_CLASS != mxGetClassID(pOutFileParams)) {
        std::stringstream buf;
        buf << "ERROR::combine_sqw => the output file parameters have to be a structure but it is not";
        mexErrMsgTxt(buf.str().c_str());
    }
    auto OutFilePar = fileParameters(pOutFileParams);
    // set up the number of bins, which is currently equal for input and output files
    OutFilePar.total_NfileBins = ProgSettings.totNumBins;

    //--------------------------------------------------------
    //-------   RUN PROGRAM      -----------------------------
    //--------------------------------------------------------
    std::vector<sqw_reader> fileReader(n_files);
    for (size_t i = 0; i < n_files; i++) {
        fileReader[i].init(fileParam[i],change_fileno,fileno_provided);
    }
    size_t n_buf_pixels(0),n_bins_processed(0);
    if (debug_file_reader) {
        auto PixBuffer = mxCreateNumericMatrix(9, ProgSettings.pixBufferSize, mxSINGLE_CLASS, mxREAL);
        if (!PixBuffer) {
            mexErrMsgTxt("Can not allocate output pixels buffer");
        }
        float *pPixBuffer = (float *)mxGetPr(PixBuffer);

        read_pix_info(pPixBuffer, n_buf_pixels, n_bins_processed, fileReader,
            ProgSettings.nBin2read,ProgSettings.totNumBins,ProgSettings.pixBufferSize);
        auto OutParam = mxCreateNumericMatrix(2, 1, mxUINT64_CLASS, mxREAL);
        uint64_t *outData = (uint64_t *)mxGetPr(OutParam);
        outData[0] = n_buf_pixels;
        outData[1] = n_bins_processed;

        plhs[pix_data] = PixBuffer;
        plhs[pix_info] = OutParam;
    }
    else {
        combine_sqw(ProgSettings, fileReader, OutFilePar);
    }
}

