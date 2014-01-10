function [ok,mess,ndet,en]=is_loader_valid_internal(this)
% check if the configured loader is properly defined and information in
% the data file corresponds to ascii par/phx file
%
%Usage:
%[ok,message,ndet,en]=loader.is_loader_valid();
%
%Returns -1 if loader is undefined,
%         0 if it is incosistant (e.g size(S) ~= size(ERR)) or size(en,1)
%         ~=size(S,2) etc...
%
mess = 'loader undefined';

ndet=[];
en  =[];

if isempty(this.file_name)
    if isempty(this.S_stor)
        ok = -1;
        return
    else
        if size(this.S_stor) ~= size(this.ERR_stor)
            ok = 0;
            mess = 'size(S) ~= size(ERR)';
            return
        end
        en  = this.en_stor;
        if size(en,1) ~=size(this.S_stor,1)+1
            ok = 0;
            mess = 'size(S,1)+1 ~= size(en)';
            return
        end
        
        n_data_detectors = size(this.S_stor,2);
    end
else  % check data in memory
    en_stor_empty = isempty(this.en_stor);
    if isempty(this.S_stor) || en_stor_empty
        % info not loaded
        if isempty(this.n_detindata_stor) || en_stor_empty
            [n_data_detectors,en]=this.get_data_info(this.file_name);
        else         % info already loaded
            n_data_detectors = this.n_detindata_stor;
            en   = this.en_stor;
        end
    else  % data and energy in memory
        n_data_detectors = size(this.S_stor,2);
        en = this.en_stor;
    end
end
%
if isempty(this.par_file_name)
    if isempty(this.n_detinpar_stor)
        if ~ismember('det_par',this.loader_defines)
            ok = -1;
            return;
        else
            % this will set up n_par_detectors = n_data_detectors 
            n_par_detectors = this.n_detectors;
        end
    else
        n_par_detectors = this.n_detinpar_stor;
    end
else
    if isempty(this.n_detectors)
        n_par_detectors = this.get_par_info(this.par_file_name,this.file_name);
    else
        n_par_detectors = this.n_detinpar_stor;
    end
end

if n_par_detectors ~= n_data_detectors
    ok = 0;
    mess=sprintf('inconsistent data and par file with data having %d detectors different from par file: %d detectors ',...
                 n_data_detectors,n_par_detectors);
else
    ok = 1;
    mess = '';
    ndet = n_par_detectors;
end
