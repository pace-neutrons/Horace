function [is,std_form] = check_sample_or_inst_array_and_return_std_form_(obj,...
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
% is       -- true, if sample_or_instrument input is convertable to
%             the standard form.
% std_form -- the standard form of sample or instrument
%             collection to store within the container

std_form = sample_or_instrument;
if isempty(sample_or_instrument)
    is = true;
    if strcmp(class_base,'IX_samp')
        std_form = {IX_null_sample()};
    else
        std_form = {IX_null_inst()};
    end
    return;
end
if iscell(sample_or_instrument)
    is = cellfun(@(x)isa(x,class_base),sample_or_instrument);
    is = all(is);
    if ~is
        std_form = {}; % will throw anyway
    end
elseif isa(sample_or_instrument,class_base)
    is = true;
    if numel(sample_or_instrument) == 1&& obj.n_runs>1 % replicate sample or instrument
        % to have the sample per each run.
        % TODO: it will be compressed container avoiding this.
        sample_or_instrument = repmat(sample_or_instrument,1,obj.n_runs);
    end
    std_form = num2cell(sample_or_instrument);
else
    is = false;
end
