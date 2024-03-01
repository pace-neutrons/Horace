function obj = check_and_set_sig_err_(obj,field_name,val)
% check if signal or error - values are acceptable
%
% Throws IX_dataset_1d:invalid_argument if they are not.
%

if isempty(val)
    obj.([field_name,'_']) = zeros(1,0);
    return;
end


if ~isa(val,'double')|| numel(size(val))~=2
    if isnumeric(val) && numel(size(val))==2
        val = double(val);
    else
        error('IX_dataset_2d:invalid_argument',...
            [field_name ' - array must be a numeric two dimensional array']);
    end
end

if size(val,1)==1
    val = val(:);
end     % make column vector

obj.([field_name,'_']) = val;

%TODO: Disabled to accomodate some oddity with 2D rebinning
% if ~isempty(obj.x_)
%     if numel(obj.([field_name,'_'])) == numel(obj.x_)+1
%         obj.x_distribution_ = false;
%     elseif numel(obj.([field_name,'_'])) == numel(obj.x_)
%         obj.x_distribution_ = true;
%     end
% end
