function obj = check_and_set_x_(obj,val)
% check if x-values are acceptable
%
% Throws IX_dataset_1d:invalid_argument if they are not.
%

if numel(size(val))==2 && all(size(val)==[0,0]) || (isempty(val))
    obj.x_ = zeros(1,0);
    return;
end

if ~isa(val,'double')||~isvector(val)
    error('IX_dataset_1d:invalid_argument',...
        'x-axis values array must be a double precision vector');
end

if ~all(isfinite(val))
    error('IX_dataset_1d:invalid_argument',...
        'Check x-axis values are all finite (i.e. no Inf or NaN)');
end
if any(diff(val)<0)
    error('IX_dataset_1d:invalid_argument',...
        'X-axis values or Histogram bin boundaries along x-axis must be strictly monotonic increasing');
    
end

if size(val,2)==1
    val = val';
end     % make row vector
obj.x_ = val;

%TODO: Disabled to accomodate some oddity with 2D rebinning
% if ~isempty(obj.signal_)
%     if numel(obj.signal_) == numel(obj.x_)+1
%         obj.x_distribution_ = false;
%     elseif numel(obj.signal_) == numel(obj.x_)
%         obj.x_distribution_ = true;
%     end
% end
