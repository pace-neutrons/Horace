function [ok,mess,obj] = check_combo_arg_(obj)
% Check if signal, error, energy and detectors array are consistent


s_eq_err = all(size(obj.S_)==size(obj.ERR_));
en_suits_s = (size(obj.en_,1) ==size(obj.S_,1)+1) || ...
    (size(obj.en_,1)==size(obj.S_,1));

if  ~(s_eq_err && en_suits_s)
    mess='ill defined ';
    if ~s_eq_err
        mess=[mess,'Signal: size(Signal) ~= size(ERR)'];
        ok = false;
        obj.isvalid_ = false;
        return;
    end
    if ~en_suits_s
        if isempty(obj.S_) && isempty(obj.ERR_)
            if is_file(obj.file_name)
                obj.isvalid_ = true;
            else
                mess = 'Energy transfer is defined but signal,error and/or data file are not';
                ok = false;
                obj.isvalid_ = false;
                return;
            end
        else
            mess = [mess,'en: size(en) ~= size(S,1)+1 or size(en) ~= size(S,1)'];
            ok = false;
            obj.isvalid_ = false;
            return;
        end
    end

end

if isempty(obj.detpar_loader_)
    mess = 'load_par undefined';
    ok = false;
    obj.isvalid_ = false;
    return
else
    n_par_detectors = obj.detpar_loader_.n_det_in_par;
end
%
if isempty(obj.S_)
    n_data_detectors  = n_par_detectors;
else
    n_data_detectors = obj.n_detindata_;
end

if n_par_detectors ~= n_data_detectors
    ok = false;
    mess=sprintf('Inconsistent data and par file with data using %d detectors and par file describes: %d detectors ',...
        n_data_detectors,n_par_detectors);
else
    ok = true;
    mess= '';
    obj.isvalid_ = true;
end

