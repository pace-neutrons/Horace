function obj = check_and_set_sig_err_(obj,field_name,val)
% check if signal or error - values are acceptable
%
% Throws IX_dataset_1d:invalid_argument if they are not.
%

if isempty(val)
    obj.([field_name,'_']) = zeros(1,0);
    return;
end

if ~isa(val,'double')||~isvector(val)
    if isnumeric(val) && isvector(val)
        val = double(val);
    else
        error('IX_dataset_1d:invalid_argument',...
            [field_name '- array must be a numeric vector']);

    end
end
% make column vector
obj.([field_name,'_']) = val(:);
