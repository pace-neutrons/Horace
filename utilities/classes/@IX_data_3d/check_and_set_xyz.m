function obj = check_and_set_xyz(obj,field_name,val)
% check if x y z  axis values are acceptable
%
% Throws IX_dataset:invalid_argument if they are not.
%

if numel(size(val))==2 && all(size(val)==[0,0]) || (isempty(val))
    obj.([field_name,'_']) = zeros(1,0);
    return;
end

if ~isa(val,'double')||~isvector(val)
    error('IX_dataset:invalid_argument',...
        '%s-axis values array must be a double precision vector',...
        field_name);
end

if ~all(isfinite(val))
    error('IX_dataset:invalid_argument',...
        '%s-axis values must all be finite (i.e. no Inf or NaN)',...
        field_name);
end
if any(diff(val)<0)
    error('IX_dataset:invalid_argument',...
        '%s-axis values or Histogram bin boundaries along x-axis must be strictly monotonically increasing',...
        field_name);
    
end

if size(val,2)==1
    val = val';
end     % make row vector
obj.([field_name,'_']) = val;

%TODO: Disabled to accomodate some oddity with 2D rebinning. Should it be
% enabled?
% if ~isempty(obj.signal_)
%     if numel(obj.signal_) == numel(obj.x_)+1
%         obj.x_distribution_ = false;
%     elseif numel(obj.signal_) == numel(obj.x_)
%         obj.x_distribution_ = true;
%     end
% end
