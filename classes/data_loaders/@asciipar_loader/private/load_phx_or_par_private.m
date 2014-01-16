function [det,loader]=load_phx_or_par_private(loader,return_array,force_reload,lext)
% method loads par data into run data structure and returns it in the format,requested by user
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
% usage:
%>>det= load_par_private(loader,return_array,force_reload,lex)
%             returns detectors information loaded from the ASCII file,
%             previously associated with the loader class
%
% loader         -- the class name of ASCII file loader class
% return_array   -- if true request to return det as 6xndet array, if false
%                   as horace structure
% force_reload   -- if true, reload det-par data even if the file name in the
%                   detectors Horace structure is already filled in and the
%                   full filename in this structure coinsides with the one,
%                   profived for file to load from.
%
%
% $Revision$ ($Date$)
%
if ~isempty(loader.det_par_stor) &&(~force_reload)
    sample = loader.par_file_name;
    [par_path,par_file,pext] = fileparts(sample);
    if isempty(par_path)
        sample = fullfile('./',[par_file,pext]);
    end
    if strcmp(fullfile(loader.det_par_stor.filepath,loader.det_par_stor.filename),sample)
        if return_array
            det=get_hor_format(load.det_par);
        else
            det = loader.det_par;
        end
        return;
    end
end
%
switch lext
    case '.par'
        par      = load_ASCII_par(loader.par_file_name);
        par(3,:) = -par(3,:);
    case '.phx'
        par = load_ASCII_phx_as_par(loader.par_file_name);
    otherwise
        error('ASCIIPAR_LOADER:load_par','unknown file extension for file %s',loader.par_file_name);
end
%
%
size_par = size(par);
ndet=size_par(2);
if get(herbert_config,'log_level')>0
    disp(['ASCIIPAR_LOADER:load_ascii_par::loaded ' num2str(ndet) ' detector(s)']);
end
%
if size_par(1)==5
    det_id = 1:ndet;
    par = [par;det_id];
elseif(size_par(1)~=6)
    error('ASCIIPAR_LOADER:load_par',' proper par file has to have 5 or 6 column but this one has %d',size_par(1));
end
%
det =  get_hor_format(par,loader.par_file_name);
loader.det_par_stor    = det;
loader.n_detinpar_stor = ndet;
%
if return_array
    det=par;
end
