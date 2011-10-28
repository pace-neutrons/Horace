function [ndet,en,this]=get_data_info(this,some_file)
% Load header information of VMS format ASCII .spe file
%
% >> [ndet,en,this] = get_data_info(loader_ascii,filename)
% >> [ndet,en,this] = get_data_info(loader_ascii)
%
% Original author: T.G.Perring
%
% $Revision: 301 $ ($Date: 2009-11-03 20:52:59 +0000 (Tue, 03 Nov 2009) $)
%
% redefime input file
if exist('some_file','var')
    if ~isa(some_file,'char')
         error('LOAD_ASCII:get_data_info',' second parameter has to be a file name');         
    end
	this.file_name = check_file_exist(some_file,'.spe');
end
%
filename = this.file_name;
if isempty(filename)
   error('ASCII_LOADER:get_data_info',' input ascii file is not defined')
end



% get info about ascii spe file;
[ne,ndet,en]= get_spe_matlab(filename,'-info_only');
if numel(en) ~= ne+1
    error('LOADER_ASCII:get_data_info',' ill formatted ascii spe file %s',filename);
end
if nargout>2
    this.en = en;
    if ~isempty(this.n_detectors)
        if this.n_detectors~=ndet
            this.par_file_name='';
        end
    end
    this.n_detectors =ndet;    
    
end

