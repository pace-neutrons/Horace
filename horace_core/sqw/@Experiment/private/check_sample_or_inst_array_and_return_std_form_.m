function std_form = check_sample_or_inst_array_and_return_std_form_(...
    sid,class_base)
% The function is the common part of the checks to set sample
% or instrument methods. Now also includes detector arrays but leaving that
% out of the function name to simplify code.
%
% check if input is sample or instrument type input and return
% standard form of the class, to store within the class method.
% Inputs:
% sid             --object or collection of objects in any
%                        standard form acceptable
%                        of samples, instruments or detectors
% class_base      --base class for samples or instruments or detectors
%                        depending on sample or instrument is
%                        verified
% Output:
% std_form -- the standard form of sample or instrument or detector
%             collection to store within the container
% Throws 'HORACE:Experiment:invalid_argument' if the input can not be
% converted into the standard form

% the sample_or_instrument container is being used in the set method for
% Experiment. Likely in loading the class from file, but maybe other uses.

% If the object saved is the current unique_references_container
% type, then just copy it into place, making sure it is the right base
% type.
if isa(sid,'unique_references_container')
    is = strcmp(class_base, sid.stored_baseclass);
    if ~is
        error('HORACE:Experiment:invalid_argument',...
            'unique_references_container of wrong type');
    end
    global_name = sid.global_name;
    std_form = sid;
    return
end

% Otherwise the container needs to be assembled. Assign the category based
% on the base class type and start a unique_references_container of the
% right category.
std_form = unique_references_container(class_base);

if isempty(sid)
    % implies the field was set empty in the constructor
    % if so allow and take no action
    ;
elseif iscell(sid)
    is = cellfun(@(x)isa(x,class_base),sid);
    if ~all(is)
        error('HORACE:Experiment:invalid_argument', ...
            'must be instrument, detector or sample but some elements of the input cellarray are not');
    end
    std_form = std_form.add(sid);
elseif isa(sid,'unique_objects_container')
    is = strcmp( sid.baseclass, std_form.stored_baseclass);
    if ~all(is)
        error('HORACE:Experiment:invalid_argument', ...
              ['must be inst, detector or sample as appropriate ', ...
               'but the input container is not']);
    end
    std_form = std_form.add(sid);
elseif isa(sid,class_base)
    std_form = std_form.add(sid);
else
    error('HORACE:Experiment:invalid_argument', ...
        ['Input must be a cellarray or array or unique_objects_container ',...
         'of %s objects . In fact it is %s'],...
        class_base,class(sid));
end
