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
        %std_form = {IX_null_sample()};
        std_form = unique_objects_container('type','{}','baseclass','IX_samp'); 
        std_form = std_form.add(IX_null_sample());
    else
        std_form = unique_objects_container('type','{}','baseclass','IX_inst'); %{IX_null_inst()};
        std_form = std_form.add(IX_null_inst());
    end
    return;
end
if isa(sample_or_instrument,'unique_objects_container')
    is = strcmp(class_base, sample_or_instrument.baseclass);
    if ~is
        %std_form = unique_objects_container('type','{}','baseclass',class_base);
        error('HORACE:check_sample_or_inst_array_and_return_std_form:invalid_argument',...
        'unique_objects_container of wrong type');
    elseif n_runs(sample_or_instrument)<1
    	error('HORACE:check_sample_or_inst_array_and_return_std_form:invalid_argument',...
    	'unique_objects_container is empty');
    end 
    % std_form has been set to sample_or_instrument above and so will not
    % be set here again - but the output from this if-block is an unchanged
    % std_form==sample_or_instrument
elseif iscell(sample_or_instrument)
    is = cellfun(@(x)isa(x,class_base),sample_or_instrument);
    is = all(is);
    if ~is
        std_form = {}; % will throw anyway
    else
        if isa(sample_or_instrument{1},'IX_samp')
            std_form = unique_objects_container('type','{}','baseclass',class_base);
            for i = 1:numel(sample_or_instrument)
                std_form = std_form.add(sample_or_instrument{i});
            end
        elseif isa(sample_or_instrument{1},'IX_inst')
            std_form = unique_objects_container('type','{}','baseclass',class_base);
            for i = 1:numel(sample_or_instrument)
                std_form = std_form.add(sample_or_instrument{i});
            end
        else
            error('HORACE:check_sample_or_inst...:invalid_argument','must be inst or sample');
        end
    end
elseif isa(sample_or_instrument,class_base)
    is = true;
    if strcmp(class_base,'IX_samp')
            std_form = unique_objects_container('type','{}','baseclass',class_base);
            if numel(sample_or_instrument)==1
                for i=1:max(1,obj.n_runs)
                    std_form = std_form.add(sample_or_instrument);
                end
            elseif numel(sample_or_instrument)==obj.n_runs
                for i=1:obj.n_runs
                    std_form = std_form.add(sample_or_instrument(i));
                end
            else
                error('HORACE:check_sample_or_inst...:invalid_argument',...
                      'number of samples must be 1 or  number of runs');
            end
    elseif strcmp(class_base,'IX_inst')
        std_form = unique_objects_container('type','{}','baseclass',class_base);
        if numel(sample_or_instrument)==1
            for i=1:max(1,obj.n_runs)
                std_form = std_form.add(sample_or_instrument);
            end
        elseif numel(sample_or_instrument)==obj.n_runs
            for i=1:obj.n_runs
                std_form = std_form.add(sample_or_instrument(i));
            end
        else
            error('HORACE:check_sample_or_inst...:invalid_argument',...
                  'number of instruments must be 1 or  number of runs');
        end
    else
        error('HORACE:check_sample_or_inst...:invalid_argument',...
              'must be inst or sample (singleton)');
    end
else
    is = false;
end
