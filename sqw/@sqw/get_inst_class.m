function [inst, all_inst] = get_inst_class (varargin)
% Determine the instrument type in a collection of sqw objects
%
%   >> inst = get_inst_class (w)                % single sqw array
%   >> inst = get_inst_class (w1, w2, ...)      % several sqw arrays
%
% Input:
% ------
%   w1,w2,...   sqw object or array of sqw objects, or cell array of objects
%
% Output:
% -------
%   inst        Default instance of the instrument class common to all runs in
%              all sqw objects
%               If there is not a common instrument class, then is returned as []
%
%   all_inst    True if instrumnets were set for all headers in all sqw objects


% Check data
sqw_objects = cellfun(@(x)isa(x,'sqw'), varargin);
if ~all(sqw_objects(:))
    error('All inputs must be sqw objects or sqw object arrays')
end
for i=1:numel(varargin)
    sqw_type = arrayfun(@(x)is_sqw_type(x), varargin{i});
    if ~all(sqw_type(:))
        error('The instrument class can only be retrieved from sqw-type data')
    end
end

% Get instrument information
inst_classes = cell(numel(varargin),1);
all_inst = false(numel(varargin),1);
for i=1:numel(varargin)
    [inst_classes{i},all_inst(i)] = get_inst_class_array(varargin{i});
end

if all(strcmp(inst_classes{1},inst_classes))
    inst = inst_classes{1};
else
    inst = '';
end
all_inst = all(all_inst);


%--------------------------------------------------------------------------
function [inst_class,all_inst] = get_inst_class_array (w)
% Determine the instrument type of an array of sqw objects

inst_classes = cell(numel(w),1);
all_inst = false(numel(w),1);
for i=1:numel(w)
    [inst_classes{i},all_inst(i)] = get_inst_class_single(w(i).header);
end

if all(strcmp(inst_classes{1},inst_classes))
    inst_class = inst_classes{1};
else
    inst_class = '';
end
all_inst = all(all_inst);


%--------------------------------------------------------------------------
function [inst_class,all_inst] = get_inst_class_single (header)
% Determine the instrument type of a single sqw object

if ~iscell(header), header = {header}; end  % for convenience, turn into a cell array

is_inst = cellfun(@(x)(isa(x.instrument,'IX_inst')), header);
if all(is_inst)
    all_inst = true;
    inst_classes = cellfun(@(x)(class(x.instrument)), header, 'uniformoutput', false);
    if all(strcmp(inst_classes{1},inst_classes))
        inst_class = inst_classes{1};
    else
        inst_class = '';
    end
else
    all_inst = false;
    inst_class = '';
end
