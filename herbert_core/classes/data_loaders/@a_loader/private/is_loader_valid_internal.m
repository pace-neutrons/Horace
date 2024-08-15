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
    if isempty(this.S_)
        ok = -1;
        return
    else
        if size(this.S_) ~= size(this.ERR_)
            ok = 0;
            mess = 'size(S) ~= size(ERR)';
            return
        end
        en  = this.en_;
        % Matlab bug? does not work if this row is provided within if
        size_ok = ((size(en,1) ==size(this.S_,1)+1)) || (size(en,1) ==size(this.S_,1));
        if ~size_ok
            ok = 0;
            mess = 'size(en) ~=size(S,1)+1 || size(en) ~=size(S,1)';
            return
        end
        n_data_detectors = size(this.S_,2);
    end
else  % check data in memory
    en_empty = isempty(this.en_);
    if isempty(this.S_) || en_empty
        % info not loaded
        if isempty(this.n_detindata_) || en_empty
            fi = this.get_data_info(this.file_name);
            n_data_detectors = fi.ndet_in_data;
            en   = fh.en;
        else         % info already loaded
            n_data_detectors = this.n_detindata_;
            en   = this.en_;
        end
    else  % data and energy in memory
        n_data_detectors = size(this.S_,2);
        en = this.en_;
    end
end
%
if isempty(this.detpar_loader_)
    mess = 'load_par undefined';
    ok = -1;
    return
else
    n_par_detectors = this.detpar_loader_.n_det_in_par;
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
