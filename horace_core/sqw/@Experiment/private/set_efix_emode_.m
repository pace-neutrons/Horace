function obj = set_efix_emode_(obj,efix,emode)
% change efix and optionally emode in all instrument descriptions

if ischar(emode) || isstring(emode)
    change_emode = false;
elseif isnumeric(emode) && emode>-1 && emode<3
    change_emode = true;
else
    error('HORACE:Experiment:invalid_argument',...
        'invalid emode specified. It can be number from 0 to 2. Actually it is %s',...
        evalc('disp(emode)'));
end

if numel(efix)>1
    multiefix = true;
    if numel(efix) ~= obj.n_runs
        error('HORACE:Experiment:invalid_argument',...
            'number of elements in efix must be one or equal to the number of experiment info. Actually n_efix = %d, n_runs= %d',...
            numel(efix),obj.n_runs);
    end
else
    multiefix = false;
end

expd = obj.expdata_;
for i=1:obj.n_runs
    if multiefix
        expd(i).efix = efix(i);
    else
        expd(i).efix = efix;
    end
    if change_emode
        expd(i).emode = emode;
    end
end
obj.expdata_ = expd;

