function val = check_xyz(val)
% check if x y z  axis values are acceptable
%
% Throws IX_dataset:invalid_argument if they are not.
%

if numel(size(val))==2 && all(size(val)==[0,0]) || (isempty(val))
    val = zeros(1,0);
    return;
end

if ~isa(val,'double')||~isvector(val)
    if isnumeric(val) && isvector(val)
        val = double(val);
    else
        error('HERBERT:IX_dataset:invalid_argument',...
            'axis values array must be a numeric vector');
    end
end

if ~all(isfinite(val))
    error('HERBERT:IX_dataset:invalid_argument',...
        'axis values must all be finite (i.e. no Inf or NaN)');
end
if any(diff(val)<0)
    error('HERBERT:IX_dataset:invalid_argument',...
        'axis values or Histogram bin boundaries along x-axis must be strictly monotonically increasing');

end

val = val(:)';  % make it row vector

%TODO: Disabled to accomodate some oddity with 2D rebinning. Should it be
% enabled?
% if ~isempty(obj.signal_)
%     if numel(obj.signal_) == numel(obj.x_)+1
%         obj.x_distribution_ = false;
%     elseif numel(obj.signal_) == numel(obj.x_)
%         obj.x_distribution_ = true;
%     end
% end
