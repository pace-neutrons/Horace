function std_form = check_sample_or_inst_array_and_return_std_form_(...
    sample_or_instrument,class_base)
% The function is the common part of the checks to set sample
% or instrument methods.
%
% check if input is sample or instrument type input and return
% standard form of the class, to store within the class method.
% Inputs:
% sample_or_instrument --object or collection of objects in any
%                        standard form acceptable
% class_base           --base class for samples or instruments
%                        depending on sample or instrument is
%                        verified
% Output:
% std_form -- the standard form of sample or instrument
%             collection to store within the container
% Throws 'HORACE:Experiment:invalid_argument' if the input can not be
% converted into the standard forn

% the sample_or_instrument container is being used in the set method for
% Experiment. Likely in loading the class from file, but maybe other uses.

% Assuming that the object saved is the current unique_references_container
% type, then just copy it into place, amking sure it is the right base
% type.
if isa(sample_or_instrument,'unique_references_container')
    is = strcmp(class_base, sample_or_instrument.stored_baseclass);
    if ~is
        error('HORACE:Experiment:invalid_argument',...
            'unique_references_container of wrong type');
    end
    global_name = sample_or_instrument.global_name;
    if strcmp(class_base, 'IX_samp') && ...
            ~strcmp(sample_or_instrument.global_name, 'GLOBAL_NAME_SAMPLES_CONTAINER')
        error('container is for samples but global container is not');
    elseif strcmp(class_base, 'IX_inst') && ...
            ~strcmp(sample_or_instrument.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER')
        error('container is for instruments but global container is not');
    end
    std_form = sample_or_instrument;
    return
end

% Otherwise the container needs to be assembled. Assign the category based
% on the base class type and start a unique_references_container of the
% right category.
if strcmp(class_base,'IX_samp')
    global_name = 'GLOBAL_NAME_SAMPLES_CONTAINER';
elseif strcmp(class_base, 'IX_inst')
    global_name = 'GLOBAL_NAME_INSTRUMENTS_CONTAINER';
else
    error('HORACE:check_sample_or_inst_array_and_return_std_form:invalid_argument', ...
          'storage base class specified is not IX_samp or IX_inst');
end
std_form = unique_references_container(global_name,class_base);

if isempty(sample_or_instrument)
    if strcmp(class_base,'IX_samp')
        std_form = std_form.add(IX_null_sample());
    else
        std_form = std_form.add(IX_null_inst());
    end
elseif iscell(sample_or_instrument)
    is = cellfun(@(x)isa(x,class_base),sample_or_instrument);
    if ~all(is)
        error('HORACE:Experiment:invalid_argument', ...
            'must be inst or sample but some elements of the input cellarray are not');
    end
    std_form = std_form.add(sample_or_instrument);
elseif isa(sample_or_instrument,'unique_objects_container');
    is = strcmp( sample_or_instrument.baseclass, std_form.stored_baseclass);
    if ~all(is)
        error('HORACE:Experiment:invalid_argument', ...
            'must be inst or sample but the input container is not');
    end
    std_form = std_form.add(sample_or_instrument);
elseif isa(sample_or_instrument,class_base)
    std_form = std_form.add(sample_or_instrument);
else
    error('HORACE:Experiment:invalid_argument', ...
        'Input must be a cellarray or array of %s objects . In fact it is %s',...
        class_base,class(sample_or_instrument));
end
