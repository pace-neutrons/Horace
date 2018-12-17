function var = get_ref_dataset_(this, var_name, test_name)
% Retrieve variable from the store for the named test
%
% Input:
% ------
%   var_name    The name of the variable to retrieve
%   test_name   The name of the test the variable belongs to
%
% Output:
% ------
%   var         Retrieved variable
%
% NOTE: for backwards compatibility with earlier versions:
% If the variable is not found in the structure for the named
% test it is looked for at the top level of the class property
% ref_data_.


if isfield(this.ref_data_,test_name) && isstruct(this.ref_data_.(test_name))
    % Structure called test_name exists - assume new format
    S = this.ref_data_.(test_name);
    if isfield(S,var_name)
        var = S.(var_name);
    else
        error('TestCaseWithSave:invalid_argument',...
            'variable: %s does not exist in stored data for the test: %s',...
            var_name,test_name);
    end
else
    % No structure called test_name exists - assume legacy format
    % of variable stored at top level, not in test_name
    if isfield(this.ref_data_,var_name)
        var = this.ref_data_.(var_name);
    else
        % Give the error message for the new format, as we assume that
        % old format files are correct (we should not be creating any new ones)
        error('TestCaseWithSave:invalid_argument',...
            'variable: %s does not exist in stored data for the test: %s',...
            var_name,test_name);
    end
end
