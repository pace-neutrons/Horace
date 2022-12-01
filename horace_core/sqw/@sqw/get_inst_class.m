function [main_inst, all_inst] = get_inst_class (obj)
% Determine the instrument type in a collection of sqw objects and retrieve
% main instrument (Single instrument?)
%
%   >> [inst,all_inst] = get_inst_class (obj)              % single sqw array
%
% Input:
% ------
%   obj,...   sqw object or array of sqw objects
%
% Output:
% -------
%   inst      Default instance of the instrument class common to all runs in
%             all sqw objects
%             If there is not a common instrument class, then is returned as []
%
%  all_inst  True if instruments were set for all headers in all sqw objects

% TODO: see ticket #917 for modification/clarification


% Check data
% Get instrument information
[inst,all_inst] = obj(1).experiment_info.get_inst_class();
if ~all_inst
    if iscell(inst)
        main_inst = inst{1};
    else
        main_inst =[];
    end
    return
end
main_inst = inst{1};
inst_type = class(main_inst);
same_type = cellfun(@(x)isa(x,inst_type),inst);
if ~same_type
    error('HORACE:tobyfit:not_implemented',...
        'Tobyfit does not currently support different types of instruments or some instruments for some runs are empty')
end
for i=2:numel(obj)
    [other_inst,all_inst] = obj(i).experiment_info.get_inst_class();
    if ~all_inst
        return
    end
    same_type = cellfun(@(x)isa(x,inst_type),other_inst);
    if ~same_type
        error('HORACE:tobyfit:not_implemented',...
            'Tobyfit does not currently support different types of instruments or some instruments for some runs are empty')
    end

end
