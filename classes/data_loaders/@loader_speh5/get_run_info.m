function [ndet,en,this]=get_run_info(this)
% Get number of detectors and energy boundaries defined by the class 
% the spe file and in connected to it ascii par or phx file
% 
% >> [ndet,en,this] = get_par_info(loader_ascii)
%  loader_ascii    -- is the initiated instance of loader_ascii file. 
%  ndet            -- number of detectors defined in par file
%  en              -- energy boundaries, defined in spe file;
%
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%
%

if ~isempty(this.n_detectors)
	ndet=this.n_detectors;
    if nargout == 1; return ; end;
end


%  there is also need to obtaion energy bounbdaries and check files
%  consistency;
filename=this.file_name;
if isempty(filename)
    error('LOADER_SPEH5:problems_with_file',' get_run_info needs spe_h5 data file to be defined');
end

data_info=find_dataset_info(filename,'','S(Phi,w)');
if isempty(data_info)
    error('LOADER_SPEH5:problems_with_file',[' can not identify the data structure location'...
        ' the file %s is not proper spe_h5 file'],filename);
end
ndet =  data_info.Dims(2);
if isempty(this.en)
    en   =  hdf5read(filename,'En_Bin_Bndrs');
else
    en    = this.en;
end
this.n_detectors = ndet;
this.en          = en;
%
% if par file defined together with she_h5 file, we need to check its
% consistency;
%
filename=this.par_file_name;
if isempty(filename)
   return;
end


fid=fopen(filename,'rt');
if fid==-1,
   error('LOADER_ASCII:problems_with_file','Error opening file %s\n',filename);
end

ndet = fscanf(fid,'%d \n',1);
fclose(fid);
if isempty(ndet)|| (ndet<0)|| (ndet> 4.2950e+009)
    error('LOADER_SPEH5:problems_with_file','Error reading number of detectors from par file %s; wrong file format?\n',filename);
end
%
if this.n_detectors ~= ndet
    error('LOADER_SPEH5:problems_with_file',' inconsitent spe_h5: %s and par: %s files. \nSPE_h5 has data for %d detectors and par describes %d detectors',...
        this.file_name,filename,this.n_detectors,ndet);
end


    



