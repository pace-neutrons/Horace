function [ok, mess,obj] = check_combo_arg(obj)
% Check interdependent fields of rundata class
%
%   >> [ok, mess] = check_combo_arg(w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.
%
%
if ~isempty(obj.lattice)
    [ok,mess,obj.lattice] = obj.lattice.check_combo_arg();
    if ~ok
        obj.isvalid_ =false;
        return;
    end
end
% Check efix
[ok,mess] = check_efix_correct(obj);
if ~ok
    obj.isvalid_ =false;
    return;
end
%
% check if the rundata object is fully defined
[undefined,~,fields_undef] = obj.check_run_defined();
if undefined >1
    obj.isvalid_=false;
    ok = false;
    mf = strjoin(fields_undef,'; ');
    mess = sprintf('Run is undefined. Need to define missing fields: %s',mf);
    return;
else
    if ~isempty(obj.loader)
        [ok,mess,obj.loader] = obj.loader.check_combo_arg();
        obj.isvalid_ = ok;
    end
end


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
        %efix = 0; %no efix for elastic mode. Just ignoring it;
    otherwise %never happens
        error('HERBERT:check_combo_arg:runtime_error',...
            'Incorrect emode has been set ignoring class protection. Error in the program logic')

end
