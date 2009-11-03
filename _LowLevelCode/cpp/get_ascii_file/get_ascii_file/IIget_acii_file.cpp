#include "get_ascii_file.h"

#define BUF_SIZE 1024
#define SPE_DATA_BLOCK_SIZE  8   // format of the data, written in SPE files (8 columns);
#define SPE_DATA_WIDTH      10   // format of the data, written in SPE files -- one symbol occupies 10 positions, if it changes here,
                                 // the format specified in the read_SPEdata_block (%g10) also has to change.
//
// low level functions to read the PAR, PHX and SPE files; Should be called from mexFunction
//
// $Revision$)
//
// the buffer specified here in static mainly for throwing meaningfull error messages;
// It would be better to specify static stringstream for that but some compuilers crash on its initialisation
// As it is here anyway, it also used as the working buffer for some functions below
static char BUF[BUF_SIZE];
/*!
*  function calculates number of changes from space to a symbol and vise versa. It used to identify the number of
*  data fields in an space-separated ascii file.
*/
int count_changes(const char *const Buf, int buf_size){
	bool is_symbol(false),is_space(true);
	int  space_to_symbol_change(0),symbol_to_space_change(0);
	for(int i=0;i<buf_size;i++){
		if(Buf[i]==0)break;
		if(Buf[i]>='+'&&Buf[i]<='z'){  // this is a symbol
			if(is_space){
				is_space=false;
				space_to_symbol_change++;
			}
			is_symbol=true;
		}
		if(Buf[i]==' '){  // this is a space
			if(is_symbol){
				is_symbol=false;
				symbol_to_space_change++;
			}
			is_space =true;
		}
	}
	return space_to_symbol_change;
}
/*!
 *  The function loads ASCII file header and tries to identify, the type of a header.
 * Possible types are
 * SPE, PAR or PHS
 *
 * if none three above identified, returns "undefined" type
*/

FileTypeDescriptor get_ASCII_header(std::string const &fileName, std::ifstream &data_stream){
	FileTypeDescriptor file_descriptor;
	file_descriptor.Type = iNumFileTypes; // set the autotype to invalid

	data_stream.open(fileName.c_str(),std::ios_base::in);
	if(!data_stream.is_open()){		throw(" Can not open existing input data file\n");
	}
	data_stream.getline(BUF,BUF_SIZE);
	if(!data_stream.good()){   		throw(" Error reading the first row of the input data file, It may be bigger then 1024 symbols\n");
	}
	//let's find if there is one or more groups of symbols inside of the buffer;
	int space_to_symbol_change=count_changes(BUF,BUF_SIZE);
	if(space_to_symbol_change>1){  // more then one group of symbols in the string, spe file
		int nDatas = sscanf(BUF," %d %d ",&file_descriptor.nData_records,&file_descriptor.nData_blocks);
		if(nDatas!=2){    			throw(" File iterpreted as SPE but does not have two numbers in the first row\n");
		}
		file_descriptor.Type=iSPE_type;
		data_stream.getline(BUF,BUF_SIZE);
		if(BUF[0]!='#'){ 			throw(" File iterpreted as SPE does not have symbol # in the second row\n");
		}
	    file_descriptor.data_start_position = data_stream.tellg(); // if it is SPE file then the data begin after the second line;
	}else{
		file_descriptor.data_start_position = data_stream.tellg(); // if it is PHX or PAR file then the data begin after the first line;
		file_descriptor.nData_records       = atoi(BUF);
		file_descriptor.nData_blocks        = 0;

		// let's ifendify now if is PHX or PAR file;
		data_stream.getline(BUF,BUF_SIZE);

		int space_to_symbol_change=count_changes(BUF,BUF_SIZE);
		if(space_to_symbol_change==6){       // PAR file
				file_descriptor.Type=iPAR_type;
		}else if(space_to_symbol_change==7){ // PHX file
				file_descriptor.Type=iPHX_type;
		}else{   // something unclear or damaged
			throw(" can not identify format of the input data file\n");
		}

	}
	return file_descriptor;
}
/*!
 *  function to load PHX or PAR file
 *  the file should be already opened and the FILE_TYPE structure properly defined using
 *  get_ASCII_header function
*/
void load_plain(std::ifstream &stream,double *pData,FileTypeDescriptor const &FILE_TYPE){
	char par_format[]=" %g %g %g %g %g";
	char phx_format[]=" %g %g %g %g %g %g %g";
	float data_buf[7];
	char *format;
	int BlockSize;

	switch(FILE_TYPE.Type){
		case(iPAR_type):{
			format = par_format;
			BlockSize=5;
			break;
						}
		case(iPHX_type):{
			format = phx_format;
			BlockSize=7;
			break;
						}
		default:			throw(" trying to load data but the data type is not recognized\n");
	}
	stream.seekg(FILE_TYPE.data_start_position,std::ios_base::beg);
	if(!stream.good()){		throw(" can not rewind the file to the initial position where the data begin\n");
	}

	int nRead_Data;
	for(unsigned int i=0;i<FILE_TYPE.nData_records;i++){
		stream.getline(BUF,BUF_SIZE);
		if(!stream.good()){	throw(" error reading input file\n");
		}

		switch(FILE_TYPE.Type){
			case(iPAR_type):{
				nRead_Data= sscanf(BUF,format,data_buf,data_buf+1,data_buf+2,data_buf+3,data_buf+4);
				break;
							}
			case(iPHX_type):{
				nRead_Data= sscanf(BUF,format,data_buf,data_buf+1,data_buf+2,data_buf+3,data_buf+4,data_buf+5,data_buf+6);
				break;
							}
		}
		if(nRead_Data!=BlockSize){
			std::stringstream err_buf;
			err_buf<<" Error reading data at file, row "<<i+1<<" column "<<nRead_Data<<" from total "<<FILE_TYPE.nData_records<<" rows, "<<BlockSize<<" columns\n";

            strcpy(BUF,err_buf.str().c_str());
			throw(const_cast<const char *>(BUF));

		}
		for(int j=0;j<nRead_Data;j++){
			pData[i*BlockSize+j]=(double)data_buf[j];
		}

	}
}
/*!
 *  function to load SPE data block; Internal function for load_spe function below
 *  the file should be already opened and the FILE_TYPE structure properly defined using
 *  get_ASCII_header function
*/

bool read_SPEdata_block(std::ifstream &stream,double *pBlock,int DataSize,std::stringstream &err_message){
	int i,j,i1,nBlock_Data;
	float data_buf;

	int nRows = DataSize/SPE_DATA_BLOCK_SIZE;
	if(nRows*SPE_DATA_BLOCK_SIZE!=DataSize)nRows++;

	int nRead_Data(0);
	for(i=0;i<nRows;i++){
		stream.getline(BUF,BUF_SIZE);
		if(!stream.good()){
			err_message<<" error obtaining string No "<<i+1<<" from the file\n";
			return false;
		}

		for(j=0;j<SPE_DATA_BLOCK_SIZE;j++){
			nBlock_Data= sscanf(BUF+j*SPE_DATA_WIDTH,"%g10",&data_buf);
			if(nBlock_Data!=1){
				if(nRead_Data!=DataSize){
					err_message<<" Error interpreting data block, row "<<i+1<<" column "<<j+1<<" from total "<<nRows<<" rows, "<<SPE_DATA_BLOCK_SIZE<<" columns\n";
					return false;
				}
			}else{
				pBlock[nRead_Data]=(double)data_buf;
				nRead_Data++;
				if(nRead_Data==DataSize)return true;
			}
		}
	}
	return true;
}
/*!
 *  function to load SPE file
 *  the file should be already opened and the FILE_TYPE structure properly defined using
 *  get_ASCII_header function
*/

void load_spe(std::ifstream &stream,double *data_S,double *data_ERR,double * data_en, FileTypeDescriptor const &FILE_TYPE){
	std::stringstream err_message;
	mwSize i,j;

	stream.seekg(FILE_TYPE.data_start_position,std::ios_base::beg);
	if(!stream.good()){		throw(" can not rewind the file to the initial position where the data begin\n");
	}
	mwSize  NDET = FILE_TYPE.nData_records;
	mwSize  NE   = FILE_TYPE.nData_blocks;
	unsigned int nRows   =    (NDET+1)/SPE_DATA_BLOCK_SIZE;
	if(nRows*SPE_DATA_BLOCK_SIZE!=(NDET+1))nRows++;

	for(i=0;i<nRows;i++){
		stream.getline(BUF,BUF_SIZE);  // read and discard Phi Grid for the time being
		if(!stream.good()){	throw(" error skiping the Phi Grid in the input file\n");
		}
	}
	stream.getline(BUF,BUF_SIZE);  // discard ###
//  energy bins
	if(!read_SPEdata_block(stream,data_en,NE+1,err_message)){
		err_message<<"          when reading the energy bins\n";
		goto Error;
	}
// read intensities + errors
	for(j=0;j<NDET;j++){
		stream.getline(BUF,BUF_SIZE);  // discard ###
		if(!read_SPEdata_block(stream,data_S +j*NE, NE,err_message)){
			err_message<<"          when reading signal, block N: "<<j+1<<std::endl;
			goto Error;
		}
		stream.getline(BUF,BUF_SIZE);  // discard ###
		if(!read_SPEdata_block(stream,data_ERR+j*NE,NE,err_message)){
			err_message<<"          when reading errors, block N: "<<j+1<<std::endl;
			goto Error;
		}

	}
	return;
Error:
    strcpy(BUF,err_message.str().c_str());
	throw(const_cast<const char *>(BUF));
}

