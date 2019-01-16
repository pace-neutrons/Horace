function this = instantiate_methods_to_save_ (this, opt)
% Check if option '-save' has been provided, and update object accordingly
%
%   >> this = instantiate_methods_to_save_ (this, opt)
%
% Input:
% ------
%   this    Instance of class
%   opt     Option. The only valid options are:
%             '-save'
%             '-save:<testMethodName>
%              (where 'save' can be abbreviated)
%           In addition, can be the name of the test suite itself which is
%           interpreted as not saving data
%
% Output:
% -------
%   obj     Updated instance of the class (unchanged if the option was the
%           class name itself). Can update properties 'save_output' and
%           'test_methods_to_save'


if ~ischarstring(opt)
    error('TEST_CASE_WITH_SAVE:invalid_argument',...
        'Option argument has to be a non-empty character string');
end

class_name = class(this);
if ~strcmp(class_name, opt)
    opt_parts = regexp(opt,':+','split');
    % Determine if '-save' option, with or without a specified method
    if numel(opt_parts{1})>=2 && opt_parts{1}(1:1)=='-' &&...
            strncmpi(opt_parts{1},'-save',numel(opt_parts{1})) &&...
            numel(opt_parts)<=2
        if numel(opt_parts)==1
            this.save_output = true;
            this.test_method_to_save_ = {};  % {} means all of the test methods
        elseif numel(opt_parts)==2
            test_methods = getTestMethods_(this);
            test_method_to_save = opt_parts{2};
            idx = find(strcmpi(test_method_to_save,test_methods));
            if ~isempty(idx)
                this.save_output = true;
                this.test_method_to_save_ = test_methods(idx);
            else
                error('TEST_CASE_WITH_SAVE:invalid_argument',...
                    'Unrecognised test method to save: "%s"',test_method_to_save)
            end
        end
    else
        error('TEST_CASE_WITH_SAVE:invalid_argument',...
            'Unrecognised option: "%s"',opt)
    end
end
