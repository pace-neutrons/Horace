function [det,loader]=load_phx_or_par_private(loader,return_horace_format,lext)
% method loads par data into run data structure and returns it in the format,requested by user
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
% usage:
%>>det= load_par_private(loader,return_horace_format)
%             returns detectors information loaded from the ASCII file, 
%             previously associated with load_ascii class by load_ascii constructor
% loader_ascii           -- the class name of ASCII file loader class
% return_horace_format   -- if present request to return the data as horace structure, if not --  as 6-column array
%
%
% $Revision: 311 $ ($Date: 2013-11-27 09:57:20 +0000 (Wed, 27 Nov 2013) $)
%
switch lext
    case '.par'
        par      = load_ASCII_par(loader.par_file_name);
        par(3,:) = -par(3,:);
    case '.phx'
        par = load_ASCII_phx_as_par(this.par_file_name);
    otherwise
        error('A_LOADER:load_ascii_par','unknown file extension for file %s',this.par_file_name);
end

    
size_par = size(par);
ndet=size_par(2);
if get(herbert_config,'log_level')>0
    disp(['A_LOADER:load_ascii_par::loaded ' num2str(ndet) ' detector(s)']);
end

if size_par(1)==5
    det_id = 1:ndet;
    par = [par;det_id];
elseif(size_par(1)~=6)
    error('A_LOADER:load_ascii_par',' proper par file has to have 5 or 6 column but this one has %d',size_par(1));
end

loader.internal_call = true;
loader.det_par     = par;
loader.internal_call = false;

if return_horace_format
  det =  get_hor_format(par,loader.par_file_name);
else
  det=par;
end


