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
% $Revision: 1 $ ($Date:  $)
%
%

if ~isempty(this.n_detectors)
	ndet=this.n_detectors;
    if nargout == 1; return ; end;
end
if ~isempty(this.en)
    en = this.en;
    return;
end
%
filename=this.par_file_name;
if isempty(filename)
    error('LOADER_ASCII:problems_with_file',' get_par_info needs ascii par file to be defined');
end


fid=fopen(filename,'rt');
if fid==-1,
   error('LOADER_ASCII:problems_with_file','Error opening file %s\n',filename);
end

ndet = fscanf(fid,'%d \n',1);
fclose(fid);
if isempty(ndet)|| (ndet<0)|| (ndet> 4.2950e+009)
    error('LOADER_ASCII:problems_with_file','Error reading number of detectors from file %s; wrong file format?\n',filename);
end
this.n_detectors=ndet;

if nargout == 1 % if one cares about ndet only, -> END; 
    return;
end
%   -->                                         -> OTHERWISE
%  there is also need to obtaion energy bounbdaries and check files
%  consistency;
filename=this.file_name;
if isempty(filename)
    error('LOADER_ASCII:problems_with_file',' get_par_info needs ascii spe file to be defined');
end
% get info about ascii spe file;
[ne,ndet_s,en]= get_spe_matlab(filename,'-info_only');
if numel(en) ~= ne+1
    error('LOADER_ASCII:problems_with_file',' ill formatted ascii spe file %s',filename);
end
%
if ndet_s ~= ndet
    error('LOADER_ASCII:problems_with_file',' inconsitent spe: %s and par: %s files. \nSPE has data for %d detectors and par describes %d detectors',...
        filename,this.par_file_name,ndet_s,ndet);
end
this.en = en;


    



