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
%   all_inst    True if instruments were set for all headers in all sqw objects




% Check data
sqw_objects = cellfun(@(x)isa(x,'sqw'), varargin);
if ~all(sqw_objects(:))
    error('HORACE:tobyfit:invalid_argument',...
        'All inputs must be sqw objects or sqw object arrays')
end
[inst,all_inst] = varargin{1}.get_inst_class();
if isempty(inst)
    return;
end
inst_type = class(inst);
% Get instrument information
for i=2:numel(varargin)
    [other_inst,all_inst] = varargin{i}.get_inst_class();
    if ~all_inst
        error('HORACE:tobyfit:invalid_argument',...
            'The object N%d does not have instrument attached to it',i);
    end
    if ~isa(other_inst,inst_type)
        error('HORACE:tobyfit:not_implemented',...
            'Instrument for oblect N%d is %s and it is different from first instrument %s\n. Tobyfit does not currently works with multiple different instruments',...
            i,class(other_inst),inst_type);
    end
end
all_inst = true;

