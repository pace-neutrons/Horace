function [this,ref_dataset]=save_or_test_variables(this,varargin)
% *************************************************************************
% Deprecated TestCaseWithSave method
%
% === DO NOT USE THIS METHOD IN NEW TEST SUITES ===
%
% This method should be replaced in units tests with the appropriate use of 
% assertEqualToTol and associated assert-with-save methods
%
% *************************************************************************
% method to test input variable in varargin against saved
% values or store these variables to the structure to save it
% later (or deal with them any other way)
%
% Usage:
%1)
%>>tc = TestCaseWithSave_child(test_name,[reference_dataset_name])
%>>tc.save_or_test_variables(a,b,c,['key1',value1,'key2',value2]);
% First row loads reference variables 'a','b','c' from
% the file with the name defined in reference_dataset_name. If
% no name is provided, default class property value is used.
% Second row compares these variables against their local values
% stored in a,b,c variables.
%
% key-value arguments are the arguments, used by equal_to_tol
% function. If no arguments are specified, default values are
% constructed from the class properties.
%
% Acceptable keys currently are:
% 'ignore_str','nan_equal','min_denominator','tol'
%
%2)
%>>tc = TestCaseWithSave_child('-save')
%>>tc.save_or_test_variables(a,b,c);
% Saves the variables 'a','b','c' in the reference dataset to
% compare against this dataset later (as in case 1)
%
% Any keys provided as input in this case stored into the
% reference file as variables.
%
%


keys = {'ignore_str','nan_equal','min_denominator','tol'};
% process input arguments, extract workspaces and set up
% default class values for arguments which are not provided
[keyval,ws_list,toll] = process_inputs_(this,keys,varargin{:});

% get the name of the calling method:
call_struct = dbstack(1);
cont=regexp(call_struct(1).name,'\.','split');
if numel(cont) > 1
    test_name = cont{end};
else
    test_name = cont{1};
end
if isempty(test_name)
    test_name  = 'interactive';
end


% assign default names to workspaces, which are the part of
% array or do not have a name for other reason
ws_names = cell(numel(ws_list),1);
for i = 1:numel(ws_list)
    ws_names{i} = inputname(i+1);
    if isempty(ws_names{i})
        ws_names{i} = [test_name,'_ws_N_',num2str(i)];
    end
end
%this.assertMethodWithSave(this, var, var_name, funcHandle, keyval{:})

% process test results and either compare it against restored
% earlier variables or set them up for saving these variables later.
for i=1:numel(ws_list)
    if not(this.save_output)
        %
        ref_dataset = this.get_ref_dataset_(ws_names{i},test_name);
        [ok,mess]=equal_to_tol(ws_list{i}, ref_dataset,toll,keyval{:});
        if ~ok && isa(ref_dataset,'IX_dataset')
            acolor('g');
            plot(ref_dataset);
            acolor('r');
            pd(ws_list{i});
            keep_figure;
        end
        assertTrue(ok,[this.errmessage_prefix,': [',ws_names{i},'] :',mess])
    else
        this = this.set_ref_dataset_(ws_list{i},ws_names{i},test_name);
    end
end


%--------------------------------------------------------------------------
function [keyval,ws_list,toll]=process_inputs_(this,keys_array,varargin)
% provess input arguments, separate control keys from workspaces
% and set up default values for keys, which are not present
%
% *************************************************************************
% Deprecated TestCaseWithSave method
% Only used by save_or_test_variables
%
% *************************************************************************

[keyval,ws_list] = extract_keyvalues(varargin,keys_array);
if numel(ws_list) == 0
    return;
end

% function decides if the variable equal to tol
f_tol_present = @(var)(is_string(var)&&strcmp(var,'tol'));
% check if var 'tol' among the input arguments
tol_provided = cellfun(f_tol_present,keyval);
if any(tol_provided)
    itol = find(tol_provided);
    toll = keyval{itol+1};
    tol_provided(itol+1)=true;
    keyval = keyval(~tol_provided);
else
    toll = this.tol;
end

f_mind_present = @(var)(is_string(var)&&strcmp(var,'min_denominator'));
mind_provided = cellfun(f_mind_present,keyval);

if ~any(mind_provided)
    if numel(keyval)>0
        keyval = [keyval(:);this.comparison_par(:)];
    else
        keyval = this.comparison_par;
    end
end
