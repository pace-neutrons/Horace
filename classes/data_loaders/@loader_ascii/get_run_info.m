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
if ~isempty(this.en)
    en = this.en;
    return;
end
%
filename=this.par_file_name;
if isempty(filename) % par files not defined
   [ndet,en]=get_spe_info(this);
   this.n_detectors=ndet;
else % get some run info  from det par
  
    ndet            =get_par_info(this); 
    this.n_detectors=ndet;

    if nargout == 1 % if one cares about ndet only, -> END; 
        return;
    end
    [ndet_s,en]=get_spe_info(this);
    if ndet_s ~= ndet
        error('LOADER_ASCII:problems_with_file',' inconsitent spe: %s and par: %s files. \nSPE has data for %d detectors and par describes %d detectors',...
            filename,this.par_file_name,ndet_s,ndet);
    end
end
this.en = en;

function [ndet,en]=get_spe_info(this)
% get run info from spe file   
filename=this.file_name;
if isempty(filename)
        error('LOADER_ASCII:problems_with_file',' get_par_info needs ascii spe file to be defined');
end
    % get info about ascii spe file;
[ne,ndet,en]= get_spe_matlab(filename,'-info_only');
if numel(en) ~= ne+1
        error('LOADER_ASCII:problems_with_file',' ill formatted ascii spe file %s',filename);
end
%

function ndet=get_par_info(this)
% get run info from par or phx file

filename=this.par_file_name;
fid=fopen(filename,'rt');
if fid==-1,
     error('LOADER_ASCII:problems_with_file','Error opening file %s\n',filename);
end

ndet = fscanf(fid,'%d \n',1);
fclose(fid);
if isempty(ndet)|| (ndet<0)|| (ndet> 4.2950e+009)
        error('LOADER_ASCII:problems_with_file','Error reading number of detectors from file %s; wrong file format?\n',filename);
end



    



