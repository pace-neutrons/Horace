function [inst, all_inst] = get_inst_class (w)
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



if ~iscell(w)
    w = {w};
end


% Perform operations
% ==================
nobj=numel(w);     % number of sqw objects or files
[inst,all_inst] = check_single(1,w{1});
if ~all_inst
    return
end
inst_type = class(main_inst);
for i=2:nobj
    win = w{i};
    [inst_x,all_inst] = check_single(i,win);
    if ~all_inst
        return
    end
    if ~isa(inst_x,inst_type)
        error('HORACE:tobyfit:not_implemented',...
            'Tobyfit does not currently support different types of instruments or some instruments for some runs in object N%d are empty', ...
            i)
    end
end
%
function [inst,all_inst] = check_single(i,win)
if ischar(win)||isstring(win)
    ldr = sqw_formats_factory.instance().get_loader(win);
    if ~ldr.sqw_type
        % Check that the data has the correct type
        error('HORACE:algorithms:invalid_argument', ...
            'Instrument can only be retrieved from sqw-type data. File N%d, name: %s does not contain sqw object', ...
            i,win)
    end
    exper = ldr.get_header('-all');
    [inst,all_inst] = exper.get_inst_class();
elseif isa(win,'sqw')
    exper = win.experiment_info;
    [inst,all_inst] = exper.get_inst_class();
else
    error('HORACE:algorithms:invalid_argument', ...
        'Instrument can only be retrieved from sqw-type data. Object N%d, has type %s', ...
        i,class(win));
end
