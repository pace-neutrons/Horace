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
    if isempty(this.S)
        ok = -1;
        return
    else
        if size(this.S) ~= size(this.ERR)
            ok = 0;
            mess = 'size(S) ~= size(ERR)';
            return
        end
        en  = this.en;
        if size(en,1) ~=size(this.S,1)+1
            ok = 0;
            mess = 'size(S,1)+1 ~= size(en)';
            return
        end
        
        ndet = size(this.S,2);
    end
else
  if isempty(this.S) || isempty(this.en)
    [ndet,en]=this.get_data_info(this.file_name);
  else
    ndet = size(this.S,2);
    en = this.en;
  end
end
%
if isempty(this.par_file_name) 
    if isempty(this.n_detectors)
        ok = -1;
        return;
    else
        n_det = this.n_detectors;
    end
else
   if isempty(this.n_detectors)    
        n_det = this.get_par_info(this.par_file_name,this.file_name);
   else
       n_det = this.n_detectors;
   end
end

if n_det ~= ndet
    ok = 0;
    mess=sprintf('inconsistent data and par file with data having %d detectors different from par file: %d detectors ',ndet,n_det);
else   
    ok = 1;
    mess = '';
end
