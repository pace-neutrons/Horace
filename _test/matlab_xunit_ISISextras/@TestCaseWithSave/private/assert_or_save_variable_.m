function  assert_or_save_variable_(this,test_name,var_name,var,funcHandle,varargin)
% Wrapper to assertion methods to enable test or save functionality
%
%   >> assertMethodWithSave (this,var_name, var,  funcHandle, varargin)
%
% Input:
% ------
%   var_name    Name of variable under which it will be saved
%   var     Variable to test or save
%
%   funcHandle  Handle to assertion function
%   varargin{:} Arguments to pass to assertion function, which has
%               the form e.g. assertVectorsAlmostEqual(A,B,varargin{:})

% Get the name of the test method. Determine this as the highest
% method of the class in the call stack that begins with 'test'
% ignoring case

% Perform the test, or save
if ~this.save_output
    stored_reference = this.get_ref_dataset_(var_name, test_name);
    funcHandle(var, stored_reference, varargin{:})
else
    this.set_ref_dataset_ (var, var_name, test_name);
end


