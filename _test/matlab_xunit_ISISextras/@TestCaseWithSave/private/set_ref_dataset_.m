function this = set_ref_dataset_(this, var, var_name, test_name)
% Save a variable to the store for the named test
%
% Input:
% ------
%   var         Variable to store
%   var_name    The name by which to save the variable
%   test_name   The name of the test with which to associate
%               the saved variable
%
% The variable will be saved in
%   this.ref_data_.(test_name).(var_name)


% Get store area for the named test, or create if doesn't exist
if isfield(this.ref_data_,test_name)
    S = this.ref_data_.(test_name);
else
    S = struct();
end
S.(var_name) = var;
this.ref_data_.(test_name) = S;
