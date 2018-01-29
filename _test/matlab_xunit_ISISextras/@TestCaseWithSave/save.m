function save (this)
% Save output of the tests to file to test against later, if requested.
%
%   >> save (this)

if ~this.save_output
    return
end

hc = herbert_config;

% Find unit test methods (begin 'test' or 'Test', excluding the constructor)
if isempty(this.test_method_to_save_)
    test_methods = getTestMethods(this);
    save_all = true;
    msg = ['Save output from test class: ',class(this)];
else
    test_methods = this.test_method_to_save_;
    save_all = false;
    msg = ['Save output from test method: ',class(this),':',test_methods{1}];
end
if hc.log_level>-1
    disp(msg)
end

% Clear reference data from possibly loaded previous datasets
this.ref_data_ = struct();

% Run test methods, when any test utilities that write to the
% object will have comparison tests deactivated because
% this.save_output is true
for i=1:numel(test_methods)
    fhandle=@(x)this.(test_methods{i});
    this.setUp();   % ensure any setup method is called
    fhandle(this);
    this.tearDown();% ensure any teardown method is called
end

% Save data, if any has been returned
if ~isempty(fieldnames(this.ref_data_))
    % Save results
    ref_data = this.ref_data_;
    if save_all
        % Saving entire test suite output
        save (this.test_results_file_, '-struct','ref_data')
    else
        % Saving only selected test method output; append or replace
        % existing test method output
        if ~exist(this.test_results_file_,'file')
            save (this.test_results_file_, '-struct','ref_data')
        else
            save (this.test_results_file_, '-struct','ref_data','-append')
        end
    end
    
    if hc.log_level>-1
        disp(' ')
        disp(['Output saved to: ',this.test_results_file_])
        disp(' ')
    end
    
else
    % No data to be saved
    if hc.log_level>-1
        disp(' ')
        disp('No data to be saved')
        disp(' ')
    end
end


