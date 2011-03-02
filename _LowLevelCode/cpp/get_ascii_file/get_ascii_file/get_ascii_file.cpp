// get_ascii_file.cpp : Defines the exported functions for the DLL application.
//
#include "get_ascii_file.h"
/*! \file get_ascii_file.cpp
*
*  \brief     result=get_ascii_file(fileName,[file_type]) function reads par, phx or spx - ASCII 
*             files depending on the output arguments specified and the file format itself
*
* usage:
*\code
* [result] = get_ascii_file(fileName,[file_type])
*
*
* input arguments: 
*	file_name -- a string which specifies the name of the input data file.
*	             The file has to be an ascii file of format specified below
*	file_type -- optional string, defining the file format
*	             three values for this string are currently possible:
*				 spe, par,  phx or nothing
*				 if omitted, the program tries to identify the file type by itself
*				 if the option is specified and the file format differs from the requested, 
*				 the error is returned
*
*output parameters:    three forms are possible:
*
*1) an ASCII Tobyfit par file
*     Syntax:
*     >> par = get_ascii_file(filename,['par'])
*
*     filename            name of par file
*
*     par(5,ndet)         contents of array
*
*         1st column      sample-detector distance
*         2nd  "          scattering angle (deg)
*         3rd  "          azimuthal angle (deg)
*                     (west bank = 0 deg, north bank = -90 deg etc.)
*                     (Note the reversed sign convention cf .phx files)
*         4th  "          width (m)
*         5th  "          height (m)
*-----------------------------------------------------------------------
*2) load an ASCII phx file
*     Syntax:
*     >> phx = get_ascii_file(filename,['phx'])
*
*     filename            name of phx file
*
*     phx(7,ndet)         contents of array
*
*     Recall that only the 3,4,5,6 columns in the file (rows in the
*     output of this routine) contain useful information
*         3rd column      scattering angle (deg)
*         4th  "          azimuthal angle (deg)
*                     (west bank = 0 deg, north bank = 90 deg etc.)
*         5th  "          angular width (deg)
*         6th  "          angular height (deg)
*-----------------------------------------------------------------------
*3) an ASCII spe file produced by homer/2d on VMS
*
*     Syntax:
*     >> [data_S, data_E, en] = get_ascii_file(filename,['spe'])
*
*     filename            name of spe file
*
*     data_S(ne,ndet)     here ndet=no. detectors, ne=no. energy bins
*     data_ERR(ne,ndet)       "
*     en(ne+1,1)          energy bin boundaries
*
*
*-----------------------------------------------------------------------
*
* $Revision$ ($Date$)
*/

/*!
* specifies the positions of the existing data files;
*/

enum inputs{
    iFileName,
    iFileType,
    iNumInputs
};
/*! \brief interface function between the code and Matlab */
void mexFunction(int nlhs, mxArray *plhs[ ],int nrhs, const mxArray *prhs[ ]){
  std::stringstream buf;  // buffer to report errors;
  char *Buf;              // buffer to get string data from Matlab

  mwSize fileName_Length;
  std::string inputFileName,inputFileType;
  fileTypes   currentFileType;
  char fileType[4];
  std::ifstream data_stream;
  FileTypeDescriptor FILE_TYPE;   // file descriptor will tell which file we have opened and some additional information about it


  std::string fileTypesAccepted[iNumFileTypes+1]; 
  fileTypesAccepted[iPAR_type]    ="par";
  fileTypesAccepted[iPHX_type]    ="phx";
  fileTypesAccepted[iSPE_type]    ="spe";
  fileTypesAccepted[iNumFileTypes]="undefined";

//--------->  ANALYSE INPUT PARAMETERS;
  const char REVISION[]="$Revision::      $ ($Date::                                              $)";
  if(nrhs==0&&nlhs==1){
        plhs[0]=mxCreateString(REVISION); 
        return;
  }

  if(nrhs!=iNumInputs&&nrhs!=iNumInputs-1) {
        buf<<"function needs one or two arguments but got "<<(short)nrhs<<" input arguments\n";	goto error;
  }
  if(!mxIsChar(prhs[iFileName])||(mxGetM(prhs[iFileName]))!=1){  // not a file name
      buf<<"first parameter has to be a scalar string, which specify a filename\n";	            goto error;
  }else{                                                         // get file name
      fileName_Length = mxGetN(prhs[iFileName])+1;
      Buf = new char[fileName_Length];
      if(!Buf){
          buf<<"auxilary memory allocation error (wrong file name?)\n";	                       goto error;
      }
      if(mxGetString(prhs[iFileName], Buf, fileName_Length)){
          buf<<"can not obtain input file_name correctly\n";			 					   goto error;
      }
      inputFileName.reserve(fileName_Length);
      inputFileName.assign(Buf);
      delete [] Buf; Buf=NULL;
//----------> INPUT PARAMETERS: does the file exist
        struct stat stFileInfo;
        if(stat(inputFileName.c_str(),&stFileInfo)!=0){ // we are not able to obtain the file info; the file probably not exist
            buf<<"file: "<<inputFileName<<" can not be found\n";							     goto error;
        }
  }

//----------> INPUT PARAMETERS: Analyse, which file type is requested
  currentFileType=iNumFileTypes; // set the current file type to the value, which it can never have for a valid file type;
  if(nrhs==iNumInputs){          // second parameter is present and we should analyse it
      if(!mxIsChar(prhs[iFileType])||(mxGetM(prhs[iFileType]))!=1){  // not a file type
            buf<<"second parameter, if present has to be a scalar string, which specify a file type\n";      goto error;
      }else{                                                         // get file type
            int fileType_Length = mxGetN(prhs[iFileType])+1;
            if(fileType_Length!=4){	buf<<"second parameter has to be a string of 3 ASCII symbols\n";	   	goto error;
            }
            if(mxGetString(prhs[iFileType], fileType, fileType_Length)){
                buf<<" can not obtain file_type properly\n";	   						goto error;
            }
            inputFileType.assign(fileType);

            // and now we should see if the parameter is among accepted
            for(int i=0;i<iNumFileTypes;i++){
                if(inputFileType.compare(fileTypesAccepted[i])==0){
                    currentFileType=(fileTypes)i;
                    break;
                }
            }
            if(currentFileType==iNumFileTypes){
                buf<<"the file type parameter, specified in the program call is: " <<inputFileType<<std::endl;
                buf<<"---------  it is not among filetypes accepted\n";                       goto error;
            }
      }
  }  // second parameter is present and have been identified;

//----------> INPUT PARAMETERS: open file and analyse,  it its type is the same as the type requested plus get other service information;
    try{
        FILE_TYPE=get_ASCII_header(inputFileName,data_stream);
    }catch(const char *Error){
        buf<<Error<<std::endl;  goto error;
    }
    if(currentFileType!=iNumFileTypes){  // then a file type reqiested is specified and we have to check if the real file type corresponds to the requested
        if(FILE_TYPE.Type!=currentFileType){
            buf<<" it is requested to open a <"<<inputFileType<<"> file, but the internal file format identified as <"<<fileTypesAccepted[FILE_TYPE.Type]<<"> file\n";
            goto error;
        }
    }
    currentFileType= FILE_TYPE.Type;


    try{
        switch(currentFileType){
            case(iPAR_type):{
                if(nlhs!=1){
                    buf<<" this program request one output parameter when loading PAR files\n";
                    goto error;
                }
                plhs[0]=mxCreateDoubleMatrix(5,FILE_TYPE.nData_records,mxREAL);
                double *pData=mxGetPr(plhs[0]);
                load_plain(data_stream,pData,FILE_TYPE);
                break;
                            }
            case(iPHX_type):{
                if(nlhs!=1){
                    buf<<" this program request one output parameter when loading PHX files\n";
                    goto error;
                }
                plhs[0]=mxCreateDoubleMatrix(7,FILE_TYPE.nData_records,mxREAL);
                double *pData=mxGetPr(plhs[0]);
                load_plain(data_stream,pData,FILE_TYPE);
                break;
                            }
            case(iSPE_type):{
                if(nlhs!=3){
                    buf<<" this program request three output parameters when loading SPE files\n";
                    buf<<" ------- [data_S, data_E, en] = get_ascii_file(filename,['spe'])\n";
                    goto error;
                }

                plhs[0]=mxCreateDoubleMatrix(FILE_TYPE.nData_blocks,FILE_TYPE.nData_records,mxREAL);
                plhs[1]=mxCreateDoubleMatrix(FILE_TYPE.nData_blocks,FILE_TYPE.nData_records,mxREAL);
                plhs[2]=mxCreateDoubleMatrix(FILE_TYPE.nData_blocks+1,1,mxREAL);
                double *data_S   = mxGetPr(plhs[0]);
                double *data_ERR = mxGetPr(plhs[1]);
                double *data_en  = mxGetPr(plhs[2]);

                load_spe(data_stream,data_S,data_ERR,data_en,FILE_TYPE);
                break;
                            }

        }
        data_stream.close();
    }catch(const char *Error){
         buf<<Error<<std::endl;  goto error;
    }

  return;
error:
  std::string err_msg("-->ERROR:: ");
  err_msg.append(buf.str());
  if(Buf)delete [] Buf;
  data_stream.close();

  mexErrMsgTxt(err_msg.c_str());

}
