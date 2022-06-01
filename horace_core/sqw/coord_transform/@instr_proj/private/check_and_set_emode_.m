function obj = check_and_set_emode_(obj,val)
if ~isnumeric(val) || numel(val)>1 || ~ismember(val,[0,1,2])
    error('HORACE:instr_proj:invalid_argument',...
        'emode should be numeric and be one of numbers [0,1,2] Actually it is: %s',...
        evalc('disp(val)'))
end
obj.emode_ = val;
%