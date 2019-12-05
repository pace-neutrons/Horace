#include "../CommonCode.h"

#include "combine_sqw.h"
#include "nsqw_pix_reader.h"
#include "sqw_pix_writer.h"

#include <memory>
#include <stdio.h>


#include <algorithm>
#include <numeric>
#include <iomanip>
#include <chrono>

enum InputArguments {
  inFileParams,
  outFileParams,
  programSettings,
  N_INPUT_Arguments
};
enum OutputArguments { // unique output arguments,
  pix_data,
  npix_in_bins,
  pix_info,
  N_OUTPUT_Arguments
};
/*
% Mex routine used to combine multiple sqw files with common grid into the single one.
%
% the routine accepts three arguments namely:
% 
% 1) inFileParams -- cellarray of the structures, which define input files and information necessary to
%                    read their pixels. The structure is processed by fileParameters class.
% The structure has the following fields:
    "file_name"         -- name of the file to process
    "npix_start_pos"    -- the location of the beginning of the npix data in the binary file 
                           (output of ftellg(fid) or of fseek(fid, npix_start_pos)
    "pix_start_pos"     -- the location of the beginning of the pix data in the binary file. Similar to npix
    "file_id"           -- number of pixel (pixel ID) distinguishing the pixels, obtained from this run from
                           all other pixels in combined sqw file.
    "nbins_total"       -- number of bins stored in single data file
%
% 2) outFileParams -- structure, which defines the parameters for the pixels to write.
    The structure is similar to the one used for inFileParams but some fields are undefined. 
    The fields need to be defined are file_name, npix_start_pos and pix_start_pos.
    The undefined fields are file_id and nbins_total
    nbins_total is calculated from nbins_total of the input files and file id 
    is the combination of file_ids of input files to can not be unique or defined.
% 
% 3) programSettings -- array of parameters defining the file combine process, namely:
% n_bin        -- number of bins in the image array
% 1            --first bin to start copy pixels for
% out_buf_size -- the size of output buffer to use for writing pixels
% log_level    -- how accurately report the progress of the mex file (if -1, no reporting occurs)
% change_fileno-- if pixel run id should be changed as below.
% relabel_with_fnum-- if change_fileno is true (1), how to calculate the new pixel
%                     id -- by providing new id equal to filenum (1) or by adding
%                     it to the existing num (0)
% num_ticks    -- approximate number of log messages to generate while
%                 combining files together
% buf size     -- buffer size -- the size of buffer used for each input file
%                 read operations
% multithreaded_combining - number, which define if or how to use multiple threads to read files and, 
                  which combining subalgorithm to deploy
*/


//--------------------------------------------------------------------------------------------------------------------
//--------- MAIN COMBINE JOB -----------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------
/* combine range of input sqw files into single output sqw file */
void combine_sqw(ProgParameters &param, std::vector<sqw_reader> &fileReaders, const fileParameters &outPar) {

  exchange_buffer Buff(param.pixBufferSize, param.totNumBins, param.num_log_ticks);

  nsqw_pix_reader Reader(param, fileReaders, Buff);

  sqw_pix_writer pixWriter(Buff);
  pixWriter.init(outPar, param.totNumBins);

  int log_level = param.log_level;

  std::thread reader([&Reader]() {
    Reader.run_read_job();
  });
  std::thread writer([&pixWriter]() {
    pixWriter.run_write_pix_job();
  });

  bool interrupted(false);
  //int count(0);
  std::mutex log_mutex;
  std::unique_lock<std::mutex> l(log_mutex);  
  int c_sensitivity(2000); // msc
  while (!Buff.is_write_job_completed()) {
    
    Buff.logging_ready.wait_for(l, std::chrono::milliseconds(c_sensitivity), [&Buff]() {return Buff.do_logging; });
    if (Buff.do_logging) {
      if (interrupted) {
        mexPrintf("%s", ".\n");
        mexEvalString("pause(.002);");
      }
      mexPrintf("%s", "\n");      
      Buff.print_log_meassage(log_level);
    }
    
    if (utIsInterruptPending()) {
      if (!interrupted) {
        mexPrintf("%s", "MEX::COMBINE_SQW: Interrupting by CTRL-C ..");
        mexEvalString("pause(.002);");
        Buff.set_interrupted("==> C-code interrupted by CTRL-C");
        c_sensitivity = 1000;
      }
      interrupted = true;
    }
    
    mexPrintf("%s", ".");
    mexEvalString("pause(.002);");
  }
  //mexPrintf("Log loop completed\n");
  //mexEvalString("pause(.002);");
  
  writer.join();
 
  reader.join();  
  Reader.finish_read_jobs();
  //mexPrintf("Reader joined\n");
  //mexEvalString("pause(.002);");
  

  if (interrupted) {
    mexPrintf("%s", ".\n");
    mexEvalString("pause(.002);");
  }
  else {
    mexPrintf("%s", "\n");      
    Buff.print_final_log_mess(log_level);
  }

  if (Buff.is_interrupted()) {
    mexErrMsgIdAndTxt("MEX_COMBINE_SQW:interrupted", Buff.error_message.c_str());
  }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  const char REVISION[] = "$Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)";
  if (nrhs == 0 && nlhs == 1) {
    plhs[0] = mxCreateString(REVISION);
    return;
  }
  //--------------------------------------------------------
  //-------   PROCESS PARAMETERS   -------------------------
  //--------------------------------------------------------
  
  

  bool debug_file_reader(false);
  size_t n_prog_params(4);
  // if pixel's run numbers id should be renamed and in which manned
  bool change_fileno(false), fileno_provided(true);
  size_t read_buf_size(4096);
  //* Check for proper number of arguments. */
  {
    if (nrhs != N_INPUT_Arguments) {
      std::stringstream buf;
      buf << "ERROR::combine_sqw needs " << (short)N_INPUT_Arguments << " but got " << (short)nrhs
        << " input arguments and " << (short)nlhs << " output argument(s)\n";
      mexErrMsgTxt(buf.str().c_str());
    }
    if (nlhs == N_OUTPUT_Arguments) {
      debug_file_reader = true;
    }
    n_prog_params = mxGetN(prhs[programSettings]);
    if (!(n_prog_params == 4 || n_prog_params == 8 || n_prog_params == 9)) {
      std::string err = "ERROR::combine_sqw => array of program parameter settings (input N 3) should have  4 or 8 or 9 elements but got: " +
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
    pCellElement = mxGetCell(pParamList, i);
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
  int read_files_multitreaded(0);

  auto pProg_settings = (double *)mxGetPr(prhs[programSettings]);

  for (size_t i = 0; i < n_prog_params; i++) {
    switch (i) {
    case(0) :
      ProgSettings.totNumBins = size_t(pProg_settings[i]);
      break;
    case(1) :
      // -1 --> convert to C-arrays from Matlab array counting
      ProgSettings.nBin2read = size_t(pProg_settings[i]) - 1;
      break;
    case(2) :
      ProgSettings.pixBufferSize = size_t(pProg_settings[i]);
      break;
    case(3) :
      ProgSettings.log_level = int(pProg_settings[i]);
      break;
    case(4) :
      change_fileno = (pProg_settings[i] > 0) ? true : false;
      break;
    case(5) :
      fileno_provided = (pProg_settings[i] > 0) ? true : false;;
      break;
    case(6) :
      ProgSettings.num_log_ticks = size_t(pProg_settings[i]);
      break;
    case(7) :
      read_buf_size = size_t(pProg_settings[i]);
      break;
    case(8) :
      read_files_multitreaded = int(pProg_settings[i]);
      break;

    }
  }
  // set up the number of bins, which has to be equal for all input files
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
    fileReader[i].init(fileParam[i], change_fileno, fileno_provided, read_buf_size, read_files_multitreaded);
  }
  size_t n_buf_pixels(0), n_bins_processed(0);
  if (debug_file_reader) {
    
    auto nbin_Buffer = mxCreateNumericMatrix(ProgSettings.totNumBins, 1, mxUINT64_CLASS, mxREAL);
    uint64_t *nbinBuf = (uint64_t *)mxGetPr(nbin_Buffer);

    exchange_buffer Buffer(ProgSettings.pixBufferSize, ProgSettings.totNumBins, ProgSettings.num_log_ticks);
    nsqw_pix_reader Reader(ProgSettings, fileReader, Buffer);


    n_bins_processed = ProgSettings.nBin2read;
    Reader.read_pix_info(n_buf_pixels, n_bins_processed, nbinBuf);

    size_t nReadPixels, n_bin_max;
    const float * buf = reinterpret_cast<const float *>(Buffer.get_write_buffer(nReadPixels, n_bin_max));
    n_bins_processed = n_bin_max - 1;
    auto PixBuffer = mxCreateNumericMatrix(9, nReadPixels, mxSINGLE_CLASS, mxREAL);
    if (!PixBuffer) {
      mexErrMsgTxt("Can not allocate output pixels buffer");
    }
    float *pPixBuffer = (float *)mxGetPr(PixBuffer);
    for (size_t i = 0; i < nReadPixels * 9; i++) {
      pPixBuffer[i] = buf[i];
    }
    Buffer.unlock_write_buffer();

    auto OutParam = mxCreateNumericMatrix(2, 1, mxUINT64_CLASS, mxREAL);
    uint64_t *outData = (uint64_t *)mxGetPr(OutParam);
    outData[0] = n_buf_pixels;
    outData[1] = n_bins_processed + 1;

    plhs[pix_data] = PixBuffer;
    plhs[npix_in_bins] = nbin_Buffer;
    plhs[pix_info] = OutParam;
  }


  else {
    combine_sqw(ProgSettings, fileReader, OutFilePar);
  }
  fileReader.clear();
}




