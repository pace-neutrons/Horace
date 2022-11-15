function [inst, all_inst] = get_inst_class (obj)
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
% Get instrument information
main_inst = obj(1).experiment_info.instruments.unique_objects;
if isempty(main_inst)
    inst = [];
    all_inst = false;
    return;
end
if numel(main_inst)>1
    error('HORACE:tobyfit:not_implemented',...
        'Tobyfit does not currently supports multiple different instruments')
end
inst_type = class(main_inst{1});
for i=2:numel(obj)
    other_inst = obj(i).experiment_info.instrument.unique_objects;
    if numel(main_inst)>1
        error('HORACE:tobyfit:not_implemented',...
            'Tobyfit does not currently works with multiple different instruments')
    end
    if ~isa(other_inst{1},inst_type)
        error('HORACE:tobyfit:not_implemented',...
            'Tobyfit currently needs the same instruments in all input sqw objects')
    end
end
inst = main_inst{1};
all_inst = true;
