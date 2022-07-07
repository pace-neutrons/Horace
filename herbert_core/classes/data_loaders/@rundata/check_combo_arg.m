function obj = check_combo_arg(obj)
% Check interdependent fields of rundata class
%
%   >>w=check_combo_arg(w)
%
%   runs successfully if interdependent variables are consistent and throws
%   "HORACE:rundata:invalid_argument" if they are not.
%
if ~isempty(obj.lattice)
    lat = obj.lattice;
    obj.isvalid_ = lat.isvalid;
    obj.reason_for_invalid_ = lat.reason_for_invalid;
    if ~obj.isvalid_
        return;
    end
end
% Check efix
[obj.isvalid_,obj.reason_for_invalid_] = check_efix_correct(obj);
if ~obj.isvalid_
    return
end
%
% check if the rundata object is fully defined
[undefined,~,fields_undef] = obj.check_run_defined();
if undefined >1
    mf = strjoin(fields_undef,'; ');
    obj.isvalid_ = false;
    obj.reason_for_invalid_ = ...
        sprintf('Run is undefined. Need to define missing fields: %s',mf);
    return;
else
    if ~isempty(obj.loader)
        ldr = obj.loader;
        ldr = ldr.check_combo_arg();
        if ~ldr.isvalid
            obj.isvalid_ = false;
            obj.reason_for_invalid_  = ldr.reason_for_invalid;
            obj.loader = ldr;
            return
        end
        obj.loader = ldr;
    end
end
obj.isvalid_ = true;
obj.reason_for_invalid_  = '';



function [ok,mess] = check_efix_correct(obj)
ok = true;
mess= '';
efix = obj.efix;
if isempty(efix) || isempty(obj.en)
    return;
end
%
histo_mode = true;
if ~isempty(obj.S)
    nen = size(obj.S,1);
    if nen == numel(obj.en) || numel(obj.en)<2
        histo_mode = false;
    end
end

switch(obj.emode)
    case(1)
        if histo_mode
            bin_bndry = 0.5*(obj.en(end)+obj.en(end-1));
        else
            bin_bndry = obj.en(end);
        end
        if (efix<bin_bndry)
            ok = false;
            mess = sprintf( ...
                'Emode=1 and efix incompatible with max energy transfer, efix: %f max(dE): %f', ...
                efix,bin_bndry);
        end
    case(2)
        efix_min = min(efix);
        if histo_mode
            bin_bndry = 0.5*(obj.en(1)+obj.en(2));
        else
            bin_bndry = obj.en(1);
        end
        n_efix = numel(efix);
        % check that if n_efix is array, its size is equal to the size of the
        % detectors array
        if n_efix>1
            if isempty(obj.S)
                ldr = obj.loader_;
                if isempty(ldr)
                    return;
                end
                n_det = ldr.n_detectors;
            else
                n_det = size(obj.S,2);
            end
            if n_det ~= n_efix
                ok = false;
                mess = sprintf( ...
                    ['Emode=2. If efix is a vector,'...
                    ' its size has to be equal to number of detectors. In fact: n_efix: %d, n_detectors: %d'],...
                    n_efix,n_det);
            end
        end

        if efix_min+bin_bndry<0
            ok = false;
            mess = sprintf( ...
                'Emode=2 and efix is incompatible with min energy transfer, efix: %f min(dE): %f', ...
                efix,bin_bndry);
        end
    case(0)
        % do nothing
        %efix = 0; %no efix for elastic mode. Just ignoring it;
    otherwise %never happens
        error('HERBERT:check_combo_arg:runtime_error',...
            'Incorrect emode: %d has been set ignoring class protection. Error in the program logic',...
            obj.emode)

end
