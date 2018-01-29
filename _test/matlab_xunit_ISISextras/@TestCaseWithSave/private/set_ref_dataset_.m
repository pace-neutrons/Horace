function this = set_ref_dataset_(this, var, var_name, test_name)
% Save a variable to the store for the named test
%
% Input:
% ------
%   var         -- variable to store
%   var_name    -- the name by which to save the variable
%   test_name   -- the name of the test with which to associate
%                  the saved variable
%
% The variable will be saved in
%   this.ref_data_.(test_name).(var_name)

% Get store area of named test, or create if doesnt exist
if isfield(this.ref_data_,test_name)
    S = this.ref_data_.(test_name);
else
    S = struct();
end
S.(var_name) = var;
this.ref_data_.(test_name) = S;
