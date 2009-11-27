#include "get_ascii_file.h"
#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#define BUF_SIZE 1024
#define SPE_DATA_BLOCK_SIZE  8   // format of the data, written in SPE files (8 columns);

//
// low level functions to read the PAR, PHX and SPE files; Should be called from mexFunction
//
// $Revision$ ($Date$)
//
// the buffer specified here in static mainly for throwing meaningfull error messages;
// It would be better to specify static stringstream for that but some compuilers crash on its initialisation
// As it is here anyway, it also used as the working buffer for some functions below
static char BUF[BUF_SIZE];
/*!
*  function calculates number of changes from space to a symbol and vise versa. It used to identify the number of
*  data fields in an space-separated ascii file.
*/
int 
count_changes(const char *const Buf, int buf_size)
{
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
/*! The function reads line from inout stream and puts it into buffer. 
*   It behaves like std::ifstream getline but the later reads additional symbol from a row in a Unix file under windows;
*/

int 
get_my_line(std::ifstream &in, char buf[], int buf_size,char DELIM)
{
	int i;
	for(i=0;i<buf_size;i++){
		in.get(buf[i]);
		if(buf[i]==DELIM){			buf[i]=0;
				return i;
		}
	}
	buf[buf_size-1]=0;
	return buf_size;
}
/*!
 *  The function loads ASCII file header and tries to identify the type of the header.
 *  Possible types are
 *  SPE, PAR or PHS
 *
 *  if none three above identified, returns "undefined" type
 *  it also returns the FileTypeDescriptor, which identifyes the position of the data in correcponding ASCII file 
 *  plus characteristics of the data extracted from correspondent data header. 
*/
FileTypeDescriptor 
get_ASCII_header(std::string const &fileName, std::ifstream &data_stream)
{
	FileTypeDescriptor file_descriptor;
	file_descriptor.Type = iNumFileTypes; // set the autotype to invalid

	data_stream.open(fileName.c_str(),std::ios_base::in|std::ios_base::binary);
	if(!data_stream.is_open()){		throw(" Can not open existing input data file\n");
	}
	// let's identify the EOL symbol; As the file may have been prepared on different OS, from where you are reading it 
	// and no conversion have been performed; 
	char symbol;
	data_stream.get(symbol);
	while(symbol>0x1F){
		data_stream.get(symbol);
	}
	char EOL;
	if(symbol==0x0D){ // Win or Mac file
			data_stream.get(symbol);
			if(symbol==0x0A){ // Windows file
				EOL=0x0A;
			}else{            // Mac
				EOL=0x0D;
			}
	}else if(symbol==0x0A){   // unix file. 
		EOL=0x0A;
	}else{
		throw(" Error reading the first row of the input ASCII data file, it contains unprintable characters (binary file? UNICODE?)\n");
	}

	file_descriptor.line_end=EOL;
	data_stream.seekg(0,std::ios::beg);


	get_my_line(data_stream,BUF,BUF_SIZE,EOL);
	if(!data_stream.good()){   		throw(" Error reading the first row of the input data file, It may be bigger then 1024 symbols\n");
	}

	//let's find if there is one or more groups of symbols inside of the buffer;
	int space_to_symbol_change=count_changes(BUF,BUF_SIZE);
	if(space_to_symbol_change>1){  // more then one group of symbols in the string, spe file
		int nDatas = sscanf(BUF," %d %d ",&file_descriptor.nData_records,&file_descriptor.nData_blocks);
		if(nDatas!=2){    			throw(" File iterpreted as SPE but does not have two numbers in the first row\n");
		}
		file_descriptor.Type=iSPE_type;
		get_my_line(data_stream,BUF,BUF_SIZE,EOL);
		if(BUF[0]!='#'){ 			throw(" File iterpreted as SPE does not have symbol # in the second row\n");
		}
	    file_descriptor.data_start_position = data_stream.tellg(); // if it is SPE file then the data begin after the second line;
	}else{
		file_descriptor.data_start_position = data_stream.tellg(); // if it is PHX or PAR file then the data begin after the first line;
		file_descriptor.nData_records       = atoi(BUF);
		file_descriptor.nData_blocks        = 0;

		// let's ifendify now if is PHX or PAR file;
		data_stream.getline(BUF,BUF_SIZE,EOL);

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
void 
load_plain(std::ifstream &stream,double *pData,FileTypeDescriptor const &FILE_TYPE)
{
	char par_format[]=" %g %g %g %g %g";
	char phx_format[]=" %g %g %g %g %g %g %g";
	float data_buf[7];
	char *format;
	int BlockSize;
	char EOL = FILE_TYPE.line_end;

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
		get_my_line(stream,BUF,BUF_SIZE,EOL);
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
 *  tr_spaces -- number of traling spaces in a data file. 
*/

bool 
read_SPEdata_block(std::ifstream &stream,double *pBlock,int DataSize,int block_size,int spe_field_width,int tr_spaces,
				   std::stringstream &err_message,char EOL,bool buf_empty=true)
{
	int i,j,nBlock_Data;
	float data_buf;
    char *DataStart = BUF+tr_spaces;
	

	char format[]="%10g";    // format string to read each data in a block
	if(spe_field_width<10||spe_field_width>99){
		sprintf(BUF," Unexpected spe field width of %d symbols has been identified; can not interpret SPE data\n",spe_field_width);
		throw(BUF);
	}
	sprintf(format+1,"%2d",spe_field_width);
	format[3]='g';


	int nRows = DataSize/block_size;
	if(nRows*block_size!=DataSize)nRows++;

	int nRead_Data(0);
	for(i=0;i<nRows;i++){
		if(buf_empty){
			get_my_line(stream,BUF,BUF_SIZE,EOL);

		}
		if(!stream.good()){
			err_message<<" error obtaining string No "<<i+1<<" from the file\n";
			return false;
		}
		for(j=0;j<block_size;j++){
//			nBlock_Data= sscanf(BUF+j*spe_data_width,%g10",&data_buf); --> C  format e.g. %g10 or %g11, the number has to correspond to  spe_data_width
			nBlock_Data= sscanf(DataStart+j*spe_field_width,format,&data_buf);

			if(nBlock_Data!=1){
				if(nRead_Data!=DataSize){
					err_message<<" Error interpreting data block, row "<<i+1<<" column "<<j+1<<" from total "<<nRows<<" rows, "<<block_size<<" columns\n";
					return false;
				}
			}else{
				pBlock[nRead_Data]=(double)data_buf;
				nRead_Data++;
				if(nRead_Data==DataSize)return true;
			}
		}
		buf_empty=true;
	}
	return true;
}
/*! the function calculates field width and traling spaces in a symbol row of SPE data to identify format of SPE data blocks
*/
void
parse_spe_row(char *buf,int buf_size,int spe_block_size, int &spe_field_width, int &trailing_spaces)
{
	int nSymbols(0),i;
	for(i=0;i<buf_size;i++){
		if(buf[i]<0x20){  // any non-printed characters including \r and \n -- up to space
		   break;
		}else{
		   nSymbols++;
		}
	}
	trailing_spaces=0;
	while(nSymbols%spe_block_size){
		nSymbols--;   
		trailing_spaces++; // some symbols at the beginning of the row can be responsible for trailing spaces;
	}
	spe_field_width=nSymbols/spe_block_size;

}
/*!
 *  function to load SPE file
 *  the file should be already opened and the FILE_TYPE structure properly defined using
 *  get_ASCII_header function
*/

void load_spe(std::ifstream &stream,double *data_S,double *data_ERR,double * data_en, FileTypeDescriptor const &FILE_TYPE){
	char BUF_RUB[BUF_SIZE];
	std::stringstream err_message;
	mwSize i,j;

	stream.seekg(FILE_TYPE.data_start_position,std::ios_base::beg);
	if(!stream.good()){		throw(" can not rewind the file to the initial position where the data begin\n");
	}
	mwSize  NDET = FILE_TYPE.nData_records;
	mwSize  NE   = FILE_TYPE.nData_blocks;
	char    EOL  = FILE_TYPE.line_end;

// read first Phi Grid line to identify the format of SPE data; it is discarded after that as currently is not used. 
	get_my_line(stream,BUF,BUF_SIZE,EOL);

	// any spe data block supposetly occupy 8 columns in a block, which is specified by SPE_DATA_BLOCK_SIZE
	int trailing_spaces(0);
	int spe_field_width(10); // format of the data, written in SPE files -- one symbol occupies 10 positions, if it changes here,
                             // the format specified in the read_SPEdata_block (%g10) also has to change.
	// analyse spe row to identify true field size
	parse_spe_row(BUF,BUF_SIZE,SPE_DATA_BLOCK_SIZE,spe_field_width,trailing_spaces);

	// here we identify number of rows in Phi grid block assuming that the data are written in bunches of SPE_DATA_BLOCK_SIZE
	mwSize nRows   =    (NDET+1)/SPE_DATA_BLOCK_SIZE;
	if(nRows*SPE_DATA_BLOCK_SIZE!=(NDET+1))nRows++;
	for(i=1;i<nRows;i++){
		get_my_line(stream,BUF,BUF_SIZE,EOL);// read and discard Phi Grid for the time being	
		if(!stream.good()){	throw(" error skiping the Phi Grid in the input file\n");
		}
	}
	get_my_line(stream,BUF_RUB,BUF_SIZE,EOL);  // discard ###
//  energy bins
	if(!read_SPEdata_block(stream,data_en,NE+1,SPE_DATA_BLOCK_SIZE,spe_field_width,trailing_spaces,err_message,EOL)){
		err_message<<"          when reading the energy bins\n";
		goto Error;
	}

// identify the block size for intensities + errors
	get_my_line(stream,BUF_RUB,BUF_SIZE,EOL);  // discard ###
	get_my_line(stream,BUF,BUF_SIZE,EOL);  // get data row;
	// analyse data row to identify true field size
	parse_spe_row(BUF,BUF_SIZE,SPE_DATA_BLOCK_SIZE,spe_field_width,trailing_spaces);
	if(spe_field_width<10||spe_field_width>99){
		err_message<<" wrong spe data field width="<<spe_field_width<<" identified when parsing first row of signal in spe file\n";
		goto Error;
	}


// read intensities + errors
	bool buf_empty(false);  // to use the data already in the buffer
	for(j=0;j<NDET;j++){
		if(buf_empty){
			get_my_line(stream,BUF_RUB,BUF_SIZE,EOL);  // discard ###
		}
		if(!read_SPEdata_block(stream,data_S +j*NE, NE,SPE_DATA_BLOCK_SIZE,spe_field_width,trailing_spaces,err_message,EOL,buf_empty)){
			err_message<<"          when reading signal, block N: "<<j+1<<std::endl;
			goto Error;
		}
		buf_empty=true;
		get_my_line(stream,BUF_RUB,BUF_SIZE,EOL);  // discard ###
		if(!read_SPEdata_block(stream,data_ERR+j*NE,NE,SPE_DATA_BLOCK_SIZE,spe_field_width,trailing_spaces,err_message,EOL)){
			err_message<<"          when reading errors, block N: "<<j+1<<std::endl;
			goto Error;
		}

	}
	return;
Error:
    strcpy(BUF,err_message.str().c_str());
	throw(const_cast<const char *>(BUF));
}

