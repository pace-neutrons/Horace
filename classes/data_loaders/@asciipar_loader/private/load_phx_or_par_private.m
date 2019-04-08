function [det,loader]=load_phx_or_par_private(loader,return_array,force_reload,getphx,lext)
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
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
if ~isempty(loader.det_par_) &&(~force_reload)
    sample = loader.par_file_name;
    [par_path,par_file,pext] = fileparts(sample);
    if isempty(par_path)
        sample = fullfile('./',[par_file,pext]);
    end
    if strcmp(fullfile(loader.det_par_.filepath,loader.det_par_.filename),sample)
        if return_array
            % this will convert par structure into array
            det=get_hor_format(loader.det_par);
        else
            det = loader.det_par;
        end
        if getphx
            det = convert_par2phx(det);
        end
        return;
    end
end
%
switch lext
    case '.par'
        rez  =  load_ASCII_par(loader.par_file_name);
        is_phx=false;
    case '.phx'
        rez  =  load_ASCII_phx(loader.par_file_name);
        is_phx = true;
    otherwise
        error('ASCIIPAR_LOADER:load_par','unknown file extension for file %s',loader.par_file_name);
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
            det = convert_par2phx(rez);
        end
    else
        if is_phx
            det = convert_phx2par(rez);
        else
            det =rez;
        end
    end
    loader_defined=false;
else
    if is_phx
        par = convert_phx2par(rez);
    else
        par = rez;
    end
    det =  get_hor_format(par,loader.par_file_name);
    loader.det_par_    = det;
    loader.n_detinpar_ = ndet;
    loader_defined=true;
end

% define loader in Horace format
if nargout >1 && ~loader_defined
    if isstruct(det)
        det_i = det;
    else
        if is_phx
            if getphx
                par = convert_phx2par(rez);
            else
                par = det;
            end            
        else
            par =rez;
        end
        det_i =  get_hor_format(par,loader.par_file_name);
    end
    loader.det_par_    = det_i;
    loader.n_detinpar_ = ndet;
    
end
%

function phx = convert_par2phx(par)
% par contains col:
%     4th  "        width (m)
%     5th  "        height (m)
%phx contains col:
%    4 	angular width e.g. delta scattered angle (deg)
%    5 	angular height e.g. delta azimuthal angle (deg)

phx = par;
phx(4,:) =(360/pi)*atan(0.5*(par(4,:)./par(1,:)));
phx(5,:) =(360/pi)*atan(0.5*(par(5,:)./par(1,:)));


function par = convert_phx2par(phx)
%phx contains col:
%    4 	angular width e.g. delta scattered angle (deg)
%    5 	angular height e.g. delta azimuthal angle (deg)
% par contains col:
%     4th  "        width (m)
%     5th  "        height (m)

par = phx;
par(4,:) =2*(phx(1,:).*tand(0.5*phx(4,:)));
par(5,:) =2*(phx(1,:).*tand(0.5*phx(5,:)));

