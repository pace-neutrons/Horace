function [det,obj]=load_phx_or_par_private(obj,return_array,force_reload,getphx,lext)
% method loads par data into run data structure and returns it in the format,requested by user
%
% this function has to have its equivalents in all other loader classes
% as all loaders are accessed through common interface.
%
% usage:
%>>det= load_par_private(loader,return_array,force_reload,lex)
%             returns detectors information loaded from the ASCII file,
%             previously associated with the loader class
%
% obj            -- the instance of ASCII par/phx file loader class
% return_array   -- if true request to return det as 6xndet array, if false
%                   as Horace structure
% force_reload   -- if true, reload det-par data even if the file name in the
%                   detectors Horace structure is already filled in and the
%                   full filename in this structure coincides with the one,
%                   provided for file to load from.
%
if ~isempty(obj.det_par_) &&(~force_reload)
    sample = obj.par_file_name;
    [par_path,par_file,pext] = fileparts(sample);
    if isempty(par_path)
        sample = fullfile('./',[par_file,pext]);
    end
    if strcmp(fullfile(obj.det_par_.filepath,obj.det_par_.filename),sample)
        if return_array
            % this will convert par structure into array
            det=get_hor_format(obj.det_par);
        else
            det = obj.det_par;
        end
        if getphx
            det = obj.convert_par2phx(det);
        end
        return;
    end
end
%
switch lext
    case '.par'
        rez  =  load_ASCII_par(obj.par_file_name);
        is_phx=false;
    case '.phx'
        rez  =  load_ASCII_phx(obj.par_file_name);
        is_phx = true;
    otherwise
        error('ASCIIPAR_LOADER:load_par','unknown file extension for file %s',obj.par_file_name);
end
%
%
size_par = size(rez);
ndet=size_par(2);
if get(herbert_config,'log_level')>0
    disp(['ASCIIPAR_LOADER:load_ascii_par::loaded ' num2str(ndet) ' detector(s)']);
end
%
if size_par(1)==5
    det_id = 1:ndet;
    rez = [rez;det_id];
elseif(size_par(1)~=6)
    error('ASCIIPAR_LOADER:load_par',' proper par file has to have 5 or 6 column but this one has %d',size_par(1));
end
%
if return_array
    if getphx
        if is_phx
            det = rez;
        else
            det = a_detpar_loader_interface.convert_par2phx(rez);
        end
    else
        if is_phx
            det = a_detpar_loader_interface.convert_phx2par(rez);
        else
            det =rez;
        end
    end
    loader_defined=false;
else
    if is_phx
        par = a_detpar_loader_interface.convert_phx2par(rez);
    else
        par = rez;
    end
    det =  get_hor_format(par,obj.par_file_name);
    obj.det_par_    = det;
    obj.n_detinpar_ = ndet;
    loader_defined=true;
end

% define loader in Horace format
if nargout >1 && ~loader_defined
    if isstruct(det)
        det_i = det;
    else
        if is_phx
            if getphx
                par = a_detpar_loader_interface.convert_phx2par(rez);
            else
                par = det;
            end            
        else
            par =rez;
        end
        det_i =  get_hor_format(par,obj.par_file_name);
    end
    obj.det_par_    = det_i;
    obj.n_detinpar_ = ndet;
    
end
%
