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
%                        of samples, instruments or detectors\
% class_base      --base class for samples or instruments or detectors
%                        depending on sample or instrument is
%                        verified
% Output:
% std_form -- the standard form of sample or instrument or detector
%             collection to store within the container
% Throws 'HORACE:Experiment:invalid_argument' if the input can not be
% converted into the standard forn

% the sample_or_instrument container is being used in the set method for
% Experiment. Likely in loading the class from file, but maybe other uses.

% If the object saved is the current unique_references_container
% type, then just copy it into place, amking sure it is the right base
% type.
if isa(sid,'unique_references_container')
    is = strcmp(class_base, sid.stored_baseclass);
    if ~is
        error('HORACE:Experiment:invalid_argument',...
            'unique_references_container of wrong type');
    end
    global_name = sid.global_name;
    if strcmp(class_base, 'IX_samp') && ...
            ~strcmp(global_name, 'GLOBAL_NAME_SAMPLES_CONTAINER')
        error('HORACE:Experiment:invalid_argument',...
              'container is for samples but global container is not');
    elseif strcmp(class_base, 'IX_inst') && ...
            ~strcmp(global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER')
        error('HORACE:Experiment:invalid_argument',...
              'container is for instruments but global container is not');
    elseif strcmp(class_base, 'IX_detector_array') && ...
            ~strcmp(global_name, 'GLOBAL_NAME_DETECTORS_CONTAINER')
        error('HORACE:Experiment:invalid_argument',...
              'container is for detectors but global container is not');
    end
    std_form = sid;
    return
end

% Otherwise the container needs to be assembled. Assign the category based
% on the base class type and start a unique_references_container of the
% right category.
if strcmp(class_base,'IX_samp')
    global_name = 'GLOBAL_NAME_SAMPLES_CONTAINER';
elseif strcmp(class_base, 'IX_inst')
    global_name = 'GLOBAL_NAME_INSTRUMENTS_CONTAINER';
elseif strcmp(class_base, 'IX_detector_array')
    global_name = 'GLOBAL_NAME_DETECTORS_CONTAINER';
else
    error('HORACE:check_sample_or_inst_array_and_return_std_form:invalid_argument', ...
          'storage base class specified is not IX_samp or IX_inst or IX_detector_array');
end
std_form = unique_references_container(global_name,class_base);

if isempty(sid)
    ; %error('prefer that empty data be dealt with before getting here');
elseif iscell(sid)
    is = cellfun(@(x)isa(x,class_base),sid);
    if ~all(is)
        error('HORACE:Experiment:invalid_argument', ...
            'must be inst or sample but some elements of the input cellarray are not');
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
        'Input must be a cellarray or array of %s objects . In fact it is %s',...
        class_base,class(sid));
end
