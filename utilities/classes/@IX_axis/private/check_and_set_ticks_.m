function obj = check_and_set_ticks_(obj,ticks)
% Method verifies axis ticks and sets axis ticks if the value is valid
%
% Throws IX_axis:invalid_argument if ticks are invalid
%
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%
%
if isempty(ticks)
    obj.ticks_ = '';
    return
end

if ~isstruct(ticks)
    error('IX_axis:invalid_argument',...
        'ticks information must be a structure with fields ''positions'' and ''labels''');
end

if ~(numel(fieldnames(ticks))==2 && all(isfield(ticks,{'positions','labels'})))
    error('IX_axis:invalid_argument',...
        'ticks information must be a structure with fields ''positions'' and ''labels''');
end

if ~isempty(ticks.labels) && numel(ticks.labels)~=numel(ticks.positions)
    error('IX_axis:invalid_argument',...
        'If tick labels are provided, the number of labels must match the number of tick positions');
end


if isempty(ticks.positions)
    obj.ticks_.positions=[];
elseif isnumeric(ticks.positions)
    if ~isrowvector(ticks.positions)
        obj.ticks_.positions=ticks.positions(:)';
    else
        obj.ticks_.positions=ticks.positions;
    end
else
    error('IX_axis:invalid_argument',...
        'tick positions must be a numeric vector')
end

if isempty(ticks.labels)
    if ~isempty(ticks.positions)
        obj.ticks_.labels=cell(1,numel(ticks.positions));        
    else
        obj.ticks_.labels={};
    end
elseif iscellstr(ticks.labels)
    if ~isrowvector(ticks.labels)
        obj.ticks_.labels=ticks.labels(:)';
    else
        obj.ticks_.labels=ticks.labels(:);
    end
elseif ischar(ticks.labels) && numel(size(ticks.labels))==2
    obj.ticks_.labels=cellstr(ticks.labels)';
else
    error('IX_axis:invalid_argument',...
        'tick labels must be a cellstr or character array');
end

obj.ticks_=orderfields(obj.ticks_,{'positions','labels'});

